package wasp.wast;

import rx.Observer;
import haxe.Int64;
import haxe.io.*;
import wasp.io.*;
import wasp.*;
import wasp.types.*;
import wasp.Global.*;
import wasp.sections.*;
import wasp.imports.*;
import wasp.disasm.Disassembly;
import wasp.operators.Ops;

/**
 * Generates WAST output from a wasm stream;
 */
class Writer {
	var buf:StringBuf;
	var m:Module;

	var fnames:NameMap;
	var funcOff:Int;

	var tab:String = "  ";

	public static function writeTo(w:StringBuf, m:Module) {
		try {
			var wr = new Writer(w, m);
			wr.writeModule();
		} catch (e:Dynamic) {
			throw e;
		}
	}

	function new(w:StringBuf, m:Module) {
		this.m = m;
		this.buf = w;
		this.fnames = new NameMap();

		var s = m.custom(CustomSectionName);
		if (s != null) {
			var names:NameSection = new NameSection();
			names.fromWasm(new BytesInput(s.data));
			var sub:FunctionNames = cast names.decode(NameFunction);
			if (sub != null) {
				this.fnames = sub.names;
			}
		}
	}

	function writeModule() {
		var bw = this.buf;

		bw.add("(module");

		this.writeTypes();
		this.writeImports();
		this.writeFunctions();
		this.writeGlobals();
		this.writeTables();
		this.writeMemory();
		this.writeExports();
		this.writeElements();
		this.writeData();

		bw.add("\n)\n");
	}

	function writeString(s:String) {
		this.buf.add(s);
	}

	function writeTypes() {
		if (this.m.types == null) {
			return;
		}

		this.writeString("\n");
		for (t in m.types.entries) {
			var i = m.types.entries.indexOf(t);
			if (i != 0) {
				writeString("\n");
			}

			this.writeString('$tab(type (;$i;) ');
			var subscriber:rx.Observer<Dynamic> = new rx.Observer(() -> {
				this.writeString(")");
			}, (error) -> throw error, null);
			this.writeFuncSignature(t).subscribe(subscriber).unsubscribe();
		}
	}

	function writeFuncSignature(t:FunctionSig) {
		return rx.Observable.create((v) -> {
			this.writeString("(func");
			var subscriber:rx.Observer<Dynamic> = new rx.Observer(() -> {
				this.writeString(")");
				v.on_completed();
			}, (error) -> throw error, null);
			writeFuncType(t).subscribe(subscriber).unsubscribe();
			return rx.Subscription.empty();
		});
	}

	function writeFuncType(t:FunctionSig) {
		return rx.Observable.create((v) -> {
			var returns = rx.Observable.create((v) -> {
				if (t.returnTypes.length != 0) {
					writeString(" (result");
					for (r in t.returnTypes) {
						writeString(' $r');
					}
					writeString(")");
					v.on_completed();
				} else {
					v.on_completed();
				}
				return rx.Subscription.empty();
			});

			var sub2 = new rx.Observer(() -> {
				v.on_completed();
			}, null, null);

			var sub1 = new rx.Observer(() -> {
				returns.subscribe(sub2).unsubscribe();
			}, null, null);
			var params = rx.Observable.create((v) -> {
				if (t.paramTypes.length != 0) {
					writeString(" (param");
					for (p in t.paramTypes) {
						writeString(' $p');
					}
					writeString(")");
					v.on_completed();
				} else {
					v.on_completed();
				}
				return rx.Subscription.empty();
			});
			params.subscribe(sub1).unsubscribe();

			return rx.Subscription.empty();
		});
	}

	function writeImports() {
		funcOff = 0;

		if (m.import_ == null)
			return;

		writeString("\n");
		for (i in 0...m.import_.entries.length) {
			var e = m.import_.entries[i];
			if (i != 0) {
				writeString("\n");
			}
			writeString('$tab(import ');
			writeString('"${e.moduleName}" "${e.fieldName}"');

			var im = e.type;
			var im_cl = Type.getClass(im);

			switch Type.getClassName(im_cl) {
				case 'wasp.imports.FuncImport':
					{
						writeString('(func (;$funcOff;) (type ${cast (im, FuncImport).type}))');
						if (fnames == null) {
							fnames = new NameMap();
						}
						var offset:I32 = funcOff;
						fnames.set(cast offset, '${e.moduleName}.${e.fieldName}');
						funcOff++;
					}
				case 'wasp.imports.TableImport': // Todo
				case 'wasp.imports.MemoryImport': // Todo
				case 'wasp.imports.GlobalVarImport': // Todo
			}
			writeString(")");
		}
	}

	function writeFunctions() {
		if (m.function_ == null)
			return;

		writeString("\n");
		var ftypes = m.function_.types;
		for (i in 0...ftypes.length) {
			var t:I32 = ftypes[i];
			if (i != 0) {
				writeString("\n");
			}
			var ind = funcOff + i;
			writeString('$tab(func ');
			if (fnames.exists(cast ind)) {
				writeString("$");
				writeString('${fnames.get(cast ind)}');
			} else {
				writeString('(;$ind;)');
			}
			writeString(' (type ${cast (t, Int)})');
			if (cast(t, Int) < m.types.entries.length) {
				var sig = m.types.entries[t];
                var sub = new rx.Observer(()->{}, null, null);
				writeFuncType(sig).subscribe(sub).unsubscribe();
			}
			if (m.code != null && i < m.code.bodies.length) {
				var b = m.code.bodies[i];
				if (b.locals.length > 0) {
					writeString('\n$tab$tab(local');
					for (l in b.locals) {
						var count:I32 = l.count;
						for (i in 0...cast(count, Int)) {
							writeString(" ");
							writeString(l.type);
						}
					}
					writeString(")");
				}
				writeCode(b.code, false);
			}
			writeString(")");
		}
	}

	function writeGlobals() {
		if (m.global == null)
			return;

		var globals = m.global.globals;
		for (e in globals) {
			var i = globals.indexOf(e);
			writeString("\n");
			writeString('$tab(global ');
			writeString('(;$i;)');
			if (e.type.mutable) {
				writeString(' (mut');
			}
			writeString(' ${e.type.type}');
			if (e.type.mutable) {
				writeString(')');
			}
			writeString(' (');
			// writeCode(e.init, true);
			// var instr = Disassembly.disassemble(e.init);
			
			// for(ins in instr){
			// 	// trace('0x${StringTools.hex(ins.op.code)}');
			// 	// // trace(ins.immediates.length);
			// 	// if(ins.immediates.length > 0){
					
			// 	// }
			// }

			var buf = new BytesInput(e.init);
			var type = e.type.type;
			var value:Dynamic = null;
			var xvalue:Dynamic = null;
			switch type {
				case ValueTypeI32:
					value = buf.readInt32();
					writeString('$type.const $value');
				case ValueTypeI64:
					value = buf.readInt32();
					writeString('$type.const $value');
				case ValueTypeF32:
					var i:I32 = FPHelper.floatToI32(buf.readFloat());
					var buf2 = new BytesOutput();
					LittleEndian.PutUint32(buf2, cast i);
					value = '0x'+buf2.getBytes().toHex();
					xvalue = FPHelper.i32ToFloat(i);
					writeString('$type.const $value (;=$xvalue;)');

				case ValueTypeF64:
					var i = buf.readDouble();
					var v:I64 = i;
					var buf2 = new BytesOutput();
					buf2.writeDouble(i);
					#if java
					var S:String = untyped __java__('Long.toHexString({0})', v);
					value = '0x${StringTools.replace(S, 'ffffffff', '')}00000000';
					// var x = untyped __java__('new java.math.BigInteger({0}, 16)', S);
					// trace(x);
					#else
					value = '0x'+buf2.getBytes().toHex();
					#end
					
					writeString('$type.const $value');	
			}
			writeString('))');
		}
	}

	function writeTables() {
		if (m.table == null)
			return;
		writeString("\n");
		var entries = m.table.entries;
		for (t in entries) {
			var i = entries.indexOf(t);
			writeString('$tab(table ');
			writeString('(;$i;)');
			writeString(' ${t.limits.initial} ${t.limits.maximum} ');
			switch t.elementType {
				case ElemTypeAnyFunc:
					{
						writeString('anyfunc');
					}
			}
			writeString(')');
		}
	}

	function writeMemory() {
		if (m.memory == null)
			return;
		writeString("\n");
		var entries = m.memory.entries;
		for (e in entries) {
			var i = entries.indexOf(e);
			writeString('$tab(memory ');
			writeString('(;$i;)');
			writeString(' ${e.limits.initial}');
			if ((e.limits.flags & 0x1) != 0) {
				writeString(' ${e.limits.maximum}');
			}
			writeString(')');
		}
	}

	function writeExports() {
		if (m.export == null)
			return;
		writeString("\n");
		var names = m.export.names;
		for (i in 0...names.length) {
			var e = m.export.entries.get(names[i]);
			if (i != 0) {
				writeString("\n");
			}
			writeString('$tab(export "${e.fieldStr}" (');
			switch e.kind {
				case ExternalFunction:
					{
						writeString("func");
					}
				case ExternalMemory:
					{
						writeString("memory");
					}
				case ExternalGlobal:
					{
						writeString("global");
					}
				case ExternalTable:
					{
						writeString("table");
					}
			}
			writeString(' ${e.index}))');
		}
	}

	function writeElements() {
		if (m.elements == null)
			return;
		var entries = m.elements.entries;
		for (d in entries) {
			writeString("\n");
			writeString('$tab(elem');
			if (d.index != 0) {
				writeString(' ${d.index}');
			}
			writeString(" (");
			writeCode(d.offset, true);

			writeString(")");
			for (v in d.elems) {
				writeString(' $v');
			}
			writeString(")");
		}
	}

	function writeData() {
		if (m.data == null)
			return;
		var entries = m.data.entries;
		for (d in entries) {
			writeString("\n");
			writeString('$tab(data');
			if (d.index != 0) {
				writeString(' ${d.index}');
			}
			writeString(" (");
			writeCode(d.offset, true);
			writeString(') "${d.data.toString()}")'); // ?? quoted Data
		}
	}

	function writeCode(code:Bytes, isInit:Bool) {
		var instr = Disassembly.disassemble(code);
		var tabs = 2;
		var block = 0;

		var writeBlock:Int->Void = (d:Int) -> {
			writeString(' $d (;@${block - d};)');
		};
		var hadEnd = false;
		for (i in 0...instr.length) {
			var ins = instr[i];
            
			if (!isInit) {
				writeString("\n");
			}
            var op = ins.op.code;

			switch op {
				case End | Else:
					{
						tabs--;
						block--;
					}
				case _:
			}
			if (isInit && !hadEnd && op == End) {
				hadEnd = true;
				continue;
			}
			if (isInit) {
				if (i > 0) {
					writeString(" ");
				}
			} else {
				for (k in 0...tabs) {
                    k;
					writeString(tab);
				}
			}
           
			writeString(ins.op.name);
			switch op {
				case Else:
					{
						tabs++;
						block++;
					}
				case Block | Loop | If:
					{
						tabs++;
						block++;
						var b:BlockType = ins.immediates[0];
						if (b != BlockTypeEmpty) {
							writeString(" (result ");
							writeString(b);
							writeString(")");
						}
						writeString('  ;; label = @${block}');
						continue;
					}
				case F32Const:
					{
						var i1:Float = ins.immediates[0];
						writeString(' ${Std.string(i1)}');
						continue;
					}
				case F64Const:
					{
						var i1:I64 = ins.immediates[0];
						writeString(' ${Int64.toStr(i1)}');
						continue;
					}
				case BrIf | Br:
					{
						var i1:U32 = ins.immediates[0];
						var _i:I32 = cast i1;
						writeBlock(_i);
						continue;
					}
				case BrTable:
					{
						var i1:U32 = ins.immediates[0];
						var n:Int = cast i1;
						for (i in 0...n) {
							var v:U32 = ins.immediates[i + 1];
							var _v:I32 = cast v;
							writeBlock(_v);
						}
						var def:U32 = ins.immediates[n + 1];
						var _def:I32 = cast def;
						writeBlock(def);
						continue;
					}
				case Call:
					{
						var i1:U32 = ins.immediates[0];
						if (fnames.exists(i1)) {
							var name = fnames.get(i1);
							writeString(" $");
							writeString(name);
						} else {
							var v:I32 = cast i1;
							writeString(' ${cast (v, Int)}');
						}
						continue;
					}
				case CallIndirect:
					{
						var i1:U32 = ins.immediates[0];
						var v:I32 = cast i1;
						writeString(' (type ${cast (v, Int)})');
						continue;
					}
				case CurrentMemory | GrowMemory:
					{
						var r:Int = ins.immediates[0];
						if (r == 0)
							continue;
					}
				case I32Store | I64Store | I32Store8 | I64Store8 | I32Store16 | I64Store16 | I64Store32 | F32Store | F64Store | I32Load | I64Load | I32Load8u | I32Load8s | I32Load16u | I32Load16s | I64Load8u | I64Load8s | I64Load16u | I64Load16s | I64Load32u | I64Load32s | F32Load | F64Load:
					{
						var i1:U32 = ins.immediates[0];
						var i2:U32 = ins.immediates[1];
						var dst = 0;
						switch cast ins.op.code {
							case I64Load | I64Store | F64Load | F64Store:
								dst = 3;
							case I32Load | I64Load32s | I64Load32u | I32Store | I64Store32 | F32Load | F32Store:
								dst = 2;
							case I32Load16u | I32Load16s | I64Load16u | I64Load16s | I32Store16 | I64Store16:
								dst = 1;
							case I32Load8u | I32Load8s | I64Load8u | I64Load8s | I32Store8 | I64Store8:
								dst = 0;
							case _:
						}
						if (i2 != 0) {
							var _i:I32 = i2;
							writeString(' offset=${cast (_i, Int)}');
						}
						var _i:I32 = i1;
						if (cast(_i, Int) != dst) {
							writeString(' align=${cast (1 << _i, Int)}');
						}
						continue;
					}
				case _:
			}
			for (a in ins.immediates) {
				writeString(" ");
				writeString('$a');
			}
		}
	}
}
