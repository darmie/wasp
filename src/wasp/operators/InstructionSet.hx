package wasp.operators;

import wasp.types.*;
// import wasp.io.*;
// import haxe.io.*;
// import binary128.internal.Leb128;
// import hex.log.HexLog.*;

enum InstructionSet {
	Op(code:Int, name:String, args:Array<ValueType>, returns:ValueType);
	OpPolymorphic(code:Int, name:String);
}

// /**
//  * StackInfo stores details about a new stack created or unwound by an instruction.
//  */
// typedef StackInfo = {
// 	// The difference between the stack depths at the end of the block
// 	?stackTopDiff:Int,
// 	// Whether the value on the top of the stack should be preserved while unwinding
// 	?preserveTop:Bool,
// 	// Whether the unwind is equivalent to a return
// 	?isReturn:Bool
// }

// /**
//  * BlockInfo stores details about a block created or ended by an instruction.
//  */
// typedef BlockInfo = {
// 	?start:Bool,
// 	// If true, this instruction starts a block. Else this instruction ends it.
// 	?signature:BlockType,

// 	// The block signature
// 	// Indices to the accompanying control operator.
// 	// For 'if', this is the index to the 'else' operator.
// 	?ifElseIndex:Int,
// 	// For 'else', this is the index to the 'if' operator.
// 	?elseIfIndex:Int,
// 	// The index to the `end' operator for if/else/loop/block.
// 	?endIndex:Int,
// 	// For end, it is the index to the operator that starts the block.
// 	?blockStartIndex:Int
// }

// typedef ISA = {
// 	?op:InstructionSet,
// 	/**
// 	 * Immediates are arguments to an operator in the bytecode stream itself.
// 	 * Valid value types are:
// 	 * - (u)(int/float)(32/64)
// 	 * - BlockType
// 	 */
// 	?immediates:Array<Dynamic>,
// 	// non-nil if the instruction creates or unwinds a stack.
// 	?newStack:StackInfo,
// 	// non-nil if the instruction starts or ends a new block.
// 	?block:BlockInfo,
// 	// whether the operator can be reached during execution
// 	?unreachable:Bool,
// 	// IsReturn is true if executing this instruction will result in the
// 	// function returning. This is true for branches (br, br_if) to
// 	// the depth <max_relative_depth> + 1, or the return operator itself.
// 	// If true, NewStack for this instruction is nil.
// 	?isReturn:Bool,
// 	// If the operator is br_table (ops.BrTable), this is a list of StackInfo
// 	// fields for each of the blocks/branches referenced by the operator.
// 	?branches:Array<StackInfo>
// }

// class Code {
// 	private var codes:Array<ISA>;

// 	public function new(fn:Function, module:Module) {
// 		this.codes = [];
// 		var instrs = disassemble(fn.body.code);

// 		trace(instrs);
// 	}

// 	private function disassemble(code:Bytes):Array<ISA> {
// 		var reader = new BytesInput(code);
// 		var instr:Array<ISA> = [];

// 		while (true) {
// 			try {
// 				var v:Ops = reader.readByte();

// 				var isa:ISA = {
// 					op: v,
// 					immediates: []
// 				}
// 				switch v {
// 					case Block | Loop | If:
// 						{
// 							var sig:BlockType = Read.byte(reader);
// 							isa.immediates.push(sig);
// 						}
// 					case Br | BrIf:
// 						{
// 							var depth = Leb128.readUint32(reader);
// 							isa.immediates.push(depth);
// 						}
// 					case BrTable:
// 						{
// 							var targetCount = Leb128.readUint32(reader);
// 							isa.immediates.push(targetCount);
// 							for (i in 0...cast(targetCount, Int)) {
// 								var entry = Leb128.readUint32(reader);
// 								isa.immediates.push(entry);
// 							}
// 							var defaultTarget = Leb128.readUint32(reader);
// 							isa.immediates.push(defaultTarget);
// 						}
// 					case Call | CallIndirect:
// 						{
// 							var index = Leb128.readUint32(reader);
// 							isa.immediates.push(index);
// 							if (v == CallIndirect) {
// 								var idx = Read.byte(reader);
// 								if (idx != 0x00) {
// 									error("table index in call_indirect must be 0");
// 									throw 'disasm: table index in call_indirect must be 0';
// 								}
// 								isa.immediates.push(idx);
// 							}
// 						}
// 					case GetGlobal | GetLocal | TeeLocal | SetLocal | SetGlobal:
// 						{
// 							var index = Leb128.readUint32(reader);
// 							isa.immediates.push(index);
// 						}
// 					case I32Const:
// 						{
// 							var i = Leb128.readUint32(reader);
// 							isa.immediates.push(i);
// 						}
// 					case I64Const:
// 						{
// 							var i = Leb128.readUint64(reader);
// 							isa.immediates.push(i);
// 						}
// 					case F32Const:
// 						{
// 							var b = Bytes.alloc(4);
// 							reader.readFullBytes(b, 0, 4);
// 							var i = LittleEndian.Uint32(b);
// 							isa.immediates.push(FPHelper.i32ToFloat(i));
// 						}
// 					case F64Const:
// 						{
// 							var b = Bytes.alloc(8);
// 							reader.readFullBytes(b, 0, 8);
// 							var i:I64 = cast LittleEndian.Uint64(b);
// 							isa.immediates.push(FPHelper.i64ToDouble(i.low, i.high));
// 						}
// 					case I32Load | I64Load | F32Load | F64Load | I32Load8s | I32Load8u | I32Load16s | I32Load16u | I64Load8s | I64Load8u | I64Load16s | I64Load16u | I64Load32s | I64Load32u | I32Store | I64Store | F32Store | F64Store | I32Store8 | I32Store16 | I64Store8 | I64Store16 | I64Store32:
// 						{
// 							// read memory_immediate
// 							var align = Leb128.readUint32(reader);
// 							isa.immediates.push(align);
// 							var offset = Leb128.readUint32(reader);
// 							isa.immediates.push(offset);
// 						}
// 					case CurrentMemory | GrowMemory:
// 						{
// 							var idx = Read.byte(reader);
// 							if (idx != 0x00) {
// 								error("memory index must be 0");
// 								throw 'disasm: memory index must be 0';
// 							}
// 							isa.immediates.push(idx);
// 						}
// 					case _:
// 				}
//                 instr.push(isa);
// 			} catch (e:Eof) {
// 				break;
// 			}
// 		}

// 		return instr;
// 	}
// }
