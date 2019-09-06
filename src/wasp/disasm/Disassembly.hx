package wasp.disasm;

import haxe.io.BytesInput;
import haxe.io.BytesOutput;
import haxe.io.Bytes;
import wasp.operators.Op;
import wasp.operators.Ops;
import wasp.types.BlockType;
import binary128.internal.Leb128;
import wasp.Function;
import wasp.Module;
import wasp.internal.Stack;
import wasp.types.FunctionSig;
import wasp.io.*;
import haxe.io.FPHelper;
import hex.log.HexLog.*;

/**
 * StackInfo stores details about a new stack created or unwound by an instruction.
 */
typedef StackInfo = {
	// The difference between the stack depths at the end of the block
	?stackTopDiff:Int,
	// Whether the value on the top of the stack should be preserved while unwinding
	?preserveTop:Bool,
	// Whether the unwind is equivalent to a return
	?isReturn:Bool
}

/**
 * BlockInfo stores details about a block created or ended by an instruction.
 */
typedef BlockInfo = {
	?start:Bool,
	// If true, this instruction starts a block. Else this instruction ends it.
	?signature:BlockType,

	// The block signature
	// Indices to the accompanying control operator.
	// For 'if', this is the index to the 'else' operator.
	?ifElseIndex:Int,
	// For 'else', this is the index to the 'if' operator.
	?elseIfIndex:Int,
	// The index to the `end' operator for if/else/loop/block.
	?endIndex:Int,
	// For end, it is the index to the operator that starts the block.
	?blockStartIndex:Int
}

/**
 * Instr describes an instruction, consisting of an operator, with its
 * appropriate immediate value(s).
 */
typedef Instr = {
	?op:Op,

	/**
	 * Immediates are arguments to an operator in the bytecode stream itself.
	 * Valid value types are:
	 * - (u)(int/float)(32/64)
	 * - BlockType
	 */
	?immediates:Array<Dynamic>,
	// non-nil if the instruction creates or unwinds a stack.
	?newStack:StackInfo,
	// non-nil if the instruction starts or ends a new block.
	?block:BlockInfo,
	// whether the operator can be reached during execution
	?unreachable:Bool,
	// IsReturn is true if executing this instruction will result in the
	// function returning. This is true for branches (br, br_if) to
	// the depth <max_relative_depth> + 1, or the return operator itself.
	// If true, NewStack for this instruction is nil.
	?isReturn:Bool,
	// If the operator is br_table (ops.BrTable), this is a list of StackInfo
	// fields for each of the blocks/branches referenced by the operator.
	?branches:Array<StackInfo>
}

/**
 * Disassembly is the result of disassembling a WebAssembly function.
 */
class Disassembly {
	public var code:Array<Instr>;

	/**
	 * The maximum stack depth that can be reached while executing this function
	 */
	public var maxDepth:Int;

	public function checkMaxDepth(depth:Int) {
		if (depth > maxDepth) {
			maxDepth = depth;
		}
	}

	public static function pushPolymorphicOp(indexStack:Array<Array<Int>>, index:Int) {
		indexStack[indexStack.length - 1].push(index);
	}

	public static function isInstrReachable(indexStack:Array<Array<Int>>):Bool {
		return indexStack[indexStack.length - 1].length == 0;
	}

	public function new(fn:Function, module:Module) {
		var code = fn.body.code;
		var instrs = disassemble(code);

		// A stack of int arrays holding indices to instructions that make the stack
		// polymorphic. Each block has its corresponding array. We start with one
		// array for the root stack
		var blockPolymorphicOps = new Array<Array<Int>>();

		// a stack of current execution stack depth values, so that the depth for each
		// stack is maintained independently for calculating discard values
		var stackDepths:Stack = new Stack();
		stackDepths.push(0);
		var blockIndices = new Stack(); // a stack of indices to operators which start new blocks

		var curIndex = 0;

		var lastOpReturn = false;

		for (instr in instrs) {
			debug('stack top is ${stackDepths.top()}');
			var opStr = instr.op;
			var op:Int = opStr.code;

			if (op == End || op == Else) {
				// There are two possible cases here:
				// 1. The corresponding block/if/loop instruction
				// *is* reachable, and an instruction somewhere in this
				// block (and NOT in a nested block) makes the stack
				// polymorphic. In this case, this end/else is reachable.
				//
				// 2. The corresponding block/if/loop instruction
				// is *not* reachable, which makes this end/else unreachable
				// too.
				var isUnreachable = blockIndices.length() != (blockPolymorphicOps.length - 1);
				instr.unreachable = isUnreachable;
			} else {
				instr.unreachable = !isInstrReachable(blockPolymorphicOps);
			}

			debug('op: ${opStr.name}, unreachable: ${instr.unreachable}');
			if (!opStr.polymorphic && !instr.unreachable) {
				var top = stackDepths.top();
				top -= opStr.args.length;
				stackDepths.setTop(top);
				if (top < -1) {
					throw new ErrStackUnderflow();
				}
				if (opStr.returns != BlockTypeEmpty) {
					top++;
					stackDepths.setTop(top);
				}

				checkMaxDepth(top);
			}

			switch op {
				case Unreachable:
					{
						pushPolymorphicOp(blockPolymorphicOps, curIndex);
					}
				case Drop:
					{
						if (!instr.unreachable) {
							stackDepths.setTop(stackDepths.top() - 1);
						}
					}
				case Select:
					{
						if (!instr.unreachable) {
							stackDepths.setTop(stackDepths.top() - 2);
						}
					}
				case Return:
					{
						if (!instr.unreachable) {
							stackDepths.setTop(stackDepths.top() - fn.sig.returnTypes.length);
						}
						pushPolymorphicOp(blockPolymorphicOps, curIndex);
						lastOpReturn = true;
					}
				case End | Else:
					{
						// The max depth reached while execing the current block
						var curDepth = stackDepths.top();
						var blockStartIndex = blockIndices.pop();
						var blockSig = this.code[blockStartIndex].block.signature;
						instr.block = {
							start: false,
							signature: blockSig
						};

						if (op == End) {
							instr.block.blockStartIndex = blockStartIndex;
							this.code[blockStartIndex].block.endIndex = curIndex;
						} else { // ops.Else
							instr.block.elseIfIndex = blockStartIndex;
							this.code[blockStartIndex].block.ifElseIndex = blockStartIndex;
						}

						// The max depth reached while execing the last block
						// If the signature of the current block is not empty,
						// this will be incremented.
						// Same with ops.Br/BrIf, we subtract 2 instead of 1
						// to get the depth of the *parent* block of the branch
						// we want to take.
						var prevDepthIndex = stackDepths.length() - 2;
						var prevDepth = stackDepths[prevDepthIndex];

						if (op != Else && blockSig != BlockTypeEmpty && !instr.unreachable) {
							stackDepths[prevDepthIndex] = prevDepth + 1;
							checkMaxDepth(stackDepths[prevDepthIndex]);
						}

						if (!lastOpReturn) {
							var elemsDiscard = curDepth - prevDepth;
							if (elemsDiscard < -1) {
								throw new ErrStackUnderflow();
							}
							instr.newStack = {
								stackTopDiff: elemsDiscard,
								preserveTop: blockSig != BlockTypeEmpty
							};

							debug('discard $elemsDiscard elements, preserve top: ${instr.newStack.preserveTop}');
						} else {
							instr.newStack = {};
						}

						debug('setting new stack for ${this.code[blockStartIndex].op.name} block (${blockStartIndex})');
						this.code[blockStartIndex].newStack = instr.newStack;

						if (!instr.unreachable) {
							blockPolymorphicOps = blockPolymorphicOps.slice(0, blockPolymorphicOps.length - 1);
						}

						stackDepths.pop();

						if (op == Else) {
							stackDepths.push(stackDepths.top());
							blockIndices.push(curIndex);
							if (!instr.unreachable) {
								blockPolymorphicOps.push([]);
							}
						}
					}
				case Block | Loop | If:
					{
						var sig:BlockType = instr.immediates[0];
						debug('if, depth is ${stackDepths.top()}');
						stackDepths.push(stackDepths.top());
						// If this new block is unreachable, its
						// entire instruction sequence is unreachable
						// as well. To make sure that isInstrReachable
						// returns the correct value, we don't push a new
						// array to blockPolymorphicOps.
						if (!instr.unreachable) {
							// Therefore, only push a new array if this instruction
							// is reachable.
							blockPolymorphicOps.push([]);
						}

						instr.block = {
							start: true,
							signature: sig
						};
						blockIndices.push(curIndex);
					}
				case Br | BrIf:
					{
						var depth = instr.immediates[0];
						if (depth == blockIndices.length()) {
							instr.isReturn = true;
						} else {
							var curDepth = stackDepths.top();
							// whenever we take a branch, the stack is unwoundd
							// to the height of stack of its *parent* block, which
							// is why we subtract 2 instead of 1.
							// prevDepth holds the height of the stack when
							// the block that we branch to started.
							var prevDepth = stackDepths[stackDepths.length() - 2 - depth];
							var elemDiscard = curDepth - prevDepth;
							if (elemDiscard < 0) {
								throw new ErrStackUnderflow();
							}

							// No need to subtract 2 here, we are getting the block
							// we need to branch to.
							var index = blockIndices[blockIndices.length() - 1 - depth];
							instr.newStack = {
								stackTopDiff: elemDiscard,
								preserveTop: this.code[index].block.signature != BlockTypeEmpty
							};
						}
						if (op == Br) {
							pushPolymorphicOp(blockPolymorphicOps, curIndex);
						}
					}
				case BrTable:
					{
						if (!instr.unreachable) {
							stackDepths.setTop(stackDepths.top() - 1);
						}
						var targetCount = instr.immediates[0];
						for (i in 0...targetCount) {
							var entry = instr.immediates[i + 1];
							var info:StackInfo = {};
							if (entry == blockIndices.length()) {
								info.isReturn = true;
							} else {
								var curDepth = stackDepths.top();
								var branchDepth = stackDepths[stackDepths.length() - 2 - entry];
								var elemsDiscard = curDepth - branchDepth;
								debug('Curdepth ${curDepth} branchDepth ${branchDepth} discard ${elemsDiscard}');

								if (elemsDiscard < 0) {
									throw new ErrStackUnderflow();
								}

								var index = blockIndices[blockIndices.length() - 1 - entry];
								info.stackTopDiff = elemsDiscard;
								info.preserveTop = this.code[index].block.signature != BlockTypeEmpty;
							}
							instr.branches.push(info);
						}
						var defaultTarget = instr.immediates[targetCount + 1];

						var info:StackInfo = {};
						if (defaultTarget == blockIndices.length()) {
							info.isReturn = true;
						} else {
							var curDepth = stackDepths.top();
							var branchDepth = stackDepths[stackDepths.length() - 2 - defaultTarget];
							var elemsDiscard = curDepth - branchDepth;

							if (elemsDiscard < 0) {
								throw new ErrStackUnderflow();
							}
							var index = blockIndices[blockIndices.length() - 1 - defaultTarget];
							info.stackTopDiff = elemsDiscard;
							info.preserveTop = this.code[index].block.signature != BlockTypeEmpty;
						}
						instr.branches.push(info);
						pushPolymorphicOp(blockPolymorphicOps, curIndex);
					}
				case Call | CallIndirect:
					{
						var index = instr.immediates[0];
						if (!instr.unreachable) {
							var sig:FunctionSig = new FunctionSig();
							var top = stackDepths.top();
							if (op == CallIndirect) {
								if (module.types == null) {
									throw "missing types section";
								}
								sig = module.types.entries[index];
								top--;
							} else {
								sig = module.getFunction(index).sig;
							}

							top -= sig.paramTypes.length;
							top += sig.returnTypes.length;
							stackDepths.setTop(top);
							checkMaxDepth(top);
						}
					}
				case GetLocal | SetLocal | TeeLocal | GetGlobal | SetGlobal:
					{
						if (!instr.unreachable) {
							var top = stackDepths.top();
							switch op {
								case GetLocal | GetGlobal: {
										top++;
										stackDepths.setTop(top);
										checkMaxDepth(top);
									}
								case SetLocal | SetGlobal: {
										top--;
										stackDepths.setTop(top);
									}
								case TeeLocal: {
										// stack remains unchanged for tee_local
									}
							}
						}
					}
			}
			if (op != Return) {
				lastOpReturn = false;
			}
			this.code.push(instr);
			curIndex++;
		}

		#if debug
		for (instr in this.code) {
			debug('${instr.op.name} ${instr.newStack}');
		}
		#end
	}

	public function disassemble(code:Bytes):Array<Instr> {
		var reader = new BytesInput(code);
		var out:Array<Instr> = [];

		while (true) {
			var op = reader.readByte();
			
			var opStr = Op.New(op);
			
			var instr:Instr = {
				op: opStr,
				immediates: []
			};

			switch op {
				case Block | Loop | If:
					{
						var sig:BlockType = Read.byte(reader);
						instr.immediates.push(sig);
					}
				case Br | BrIf:
					{
						var depth = Leb128.readUint32(reader);
						instr.immediates.push(depth);
					}
				case BrTable:
					{
						var targetCount = Leb128.readUint32(reader);
						instr.immediates.push(targetCount);
						for (i in 0...cast(targetCount, Int)) {
							var entry = Leb128.readUint32(reader);
							instr.immediates.push(entry);
						}
						var defaultTarget = Leb128.readUint32(reader);
						instr.immediates.push(defaultTarget);
					}
				case Call | CallIndirect:
					{
						var index = Leb128.readUint32(reader);
						instr.immediates.push(index);
						if (op == CallIndirect) {
							var idx = Read.byte(reader);
							if (idx != 0x00) {
								error("table index in call_indirect must be 0");
								throw 'disasm: table index in call_indirect must be 0';
							}
							instr.immediates.push(idx);
						}
					}
				case GetGlobal | GetLocal | TeeLocal | SetLocal | SetGlobal:
					{
						var index = Leb128.readUint32(reader);
						instr.immediates.push(index);
					}
				case I32Const:
					{
						var i = Leb128.readUint32(reader);
						instr.immediates.push(i);
					}
				case I64Const:
					{
						var i = Leb128.readUint64(reader);
						instr.immediates.push(i);
					}
				case F32Const:
					{
						var b = Bytes.alloc(4);
						reader.readFullBytes(b, 0, 4);
						var i = LittleEndian.Uint32(b);
						instr.immediates.push(FPHelper.i32ToFloat(i));
					}
				case F64Const:
					{
						var b = Bytes.alloc(8);
						reader.readFullBytes(b, 0, 8);
						var i:I64 = cast LittleEndian.Uint64(b);
						instr.immediates.push(FPHelper.i64ToDouble(i.low, i.high));
					}
				case I32Load | I64Load | F32Load | F64Load | I32Load8s | I32Load8u | I32Load16s | I32Load16u | I64Load8s | I64Load8u | I64Load16s | I64Load16u | I64Load32s | I64Load32u | I32Store | I64Store | F32Store | F64Store | I32Store8 | I32Store16 | I64Store8 | I64Store16 | I64Store32:
					{
						// read memory_immediate
						var align = Leb128.readUint32(reader);
						instr.immediates.push(align);
						var offset = Leb128.readUint32(reader);
						instr.immediates.push(offset);
					}
				case CurrentMemory | GrowMemory:
					{
						var idx = Read.byte(reader);
						if (idx != 0x00) {
							error("memory index must be 0");
							throw 'disasm: memory index must be 0';
						}
						instr.immediates.push(idx);
					}
			}
			out.push(instr);
		}

		return out;
	}

	public static function assemble(instr:Array<Instr>):Bytes {
		var body = new BytesOutput();

		for (ins in instr) {
			body.writeByte(ins.op.code);
			var op = ins.op.code;
			switch op {
				case Block | Loop | If:
					{
						body.writeByte(ins.immediates[0]);
					}
				case Br | BrIf:
					{
						Leb128.writeUint32(body, ins.immediates[0]);
					}

				case BrTable:
					{
						var cnt:Int = ins.immediates[0];
						Leb128.writeUint32(body, cnt);
						for (i in 0...cnt) {
							Leb128.writeUint32(body, ins.immediates[i + 1]);
						}
						Leb128.writeUint32(body, ins.immediates[1 + cnt]);
					}

				case Call | CallIndirect:
					{
						Leb128.writeUint32(body, ins.immediates[0]);
						if (op == Ops.CallIndirect) {
							Leb128.writeUint32(body, ins.immediates[1]);
						}
					}
				case GetLocal | SetLocal | TeeLocal | GetGlobal | SetGlobal:
					{
						Leb128.writeUint32(body, ins.immediates[0]);
					}

				case I32Const:
					{
						Leb128.writeInt32(body, ins.immediates[0]);
					}

				case I64Const:
					{
						Leb128.writeInt64(body, ins.immediates[0]);
					}

				case F32Const:
					{
						var f = ins.immediates[0];
						body.writeFloat(f);
					}
				case F64Const:
					{
						body.writeDouble(ins.immediates[0]);
					}

				case I32Load | I64Load | F32Load | F64Load | I32Load8s | I32Load8u | I32Load16s | I32Load16u | I64Load8s | I64Load8u | I64Load16s | I64Load16u | I64Load32s | I64Load32u | I32Store | I64Store | F32Store | I32Store8 | I32Store16 | I64Store8 | I64Store16 | I64Store32:
					{
						Leb128.writeUint32(body, ins.immediates[0]);
						Leb128.writeUint32(body, ins.immediates[1]);
					}

				case CurrentMemory | GrowMemory:
					{
						Leb128.writeUint32(body, ins.immediates[1]);
					}
			}
		}

		return body.getBytes();
	}
}

/**
 * Stack Underflow Error
 */
abstract ErrStackUnderflow(String) {
	public inline function new() {
		this = "";
	}

	@:to public inline function toString():String {
		return "disasm: stack underflow";
	}
}
