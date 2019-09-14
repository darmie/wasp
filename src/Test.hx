package;

import wasp.sections.FunctionNames;
import wasp.types.ExportEntry;
import wasp.types.GlobalEntry;
import wasp.io.LittleEndian;
import haxe.io.FPHelper;
import wasp.io.Read;
import binary128.internal.Leb128;
import haxe.io.BytesBuffer;
import haxe.io.Bytes;
import haxe.io.BytesOutput;
import wasp.io.ReadPos;
import wasp.Module;
import wasp.disasm.Disassembly;
import haxe.io.BytesInput;
import sys.FileSystem;
import sys.io.File;

// private class ReadPosTest {
// 	public function new(){
// 		var data = new BytesOutput();
// 		data.writeByte(0);
// 		data.writeByte(1);
// 		data.writeByte(2);
// 		data.writeByte(3);
// 		data.writeByte(4);
// 		data.writeByte(5);
// 		data.writeByte(6);
// 		data.writeByte(7);
// 		data.writeByte(8);
// 		data.writeByte(9);
// 		var r = new BytesInput(Bytes.alloc(0));
// 		var reader:ReadPos = new ReadPos(r);
// 		var b = Bytes.alloc(2);
// 		var n = reader.readBytes(b);
// 		trace('n == 0 : ${n} ${n == 0}');
// 	}
// }
class Test {
	public static function main() {
		// new ReadPosTest();
		new Test();
	}

	public function new() {
		try {
			var source = FileSystem.fullPath("globals.wasm");
			if (FileSystem.exists(source)) {
				var raw = File.getBytes(source);

				var r = new BytesInput(raw);

				var m = Module.read(r, null);

				var sbuf = new StringBuf();

				for (section in m.sections) {
					switch section.sectionID() {
						case SectionIDGlobal:
							{
								getGlobals(m.globalIndexSpace, sbuf);
							}
						case SectionIDExport:
							{
								for (export in m.export.entries) {
									var exp:Dynamic = null;
									switch export.kind {
										case ExternalFunction: {
												var func = m.getFunction(export.index);
												getFunctions(func, sbuf, true, export);
											}
										case ExternalGlobal: {
												var globs = m.globalIndexSpace;
												getGlobals(globs, sbuf, true, export);
											}
										case ExternalMemory: {
												exp = 'memory';
												for (mem in m.memory.entries) {}
											}
										case ExternalTable: exp = 'table';
									}

									sbuf.add('\n');
								}
								sbuf.add('\n');
							}
						case SectionIDCode: {
							for(body in m.code.bodies){
								for (local in body.locals){
									trace(local);
								}
							}
						}
						case SectionIDCustom:{
							trace(m.customs[0].name);
						}
						case SectionIDFunction: {
							// trace(m.function_.types);
							// trace(m.function_.)
						}
						case SectionIDType: {
							// trace(m.types.entries);
						}
						case _:
					}
				}
				Sys.println(sbuf.toString());
			}
		} catch (e:Dynamic) {
			throw e;
		}
	}

	static function getFunctions(func:wasp.Function, sbuf:StringBuf, isExport:Bool = false, export:ExportEntry = null) {
		var hasParams = func.sig.paramTypes.length != 0;
		var hasReturn = func.sig.returnTypes.length != 0;
		if (isExport) {
			sbuf.add("("); // open
			sbuf.add("func ");
			sbuf.add("("); // open
			sbuf.add('export "${export.fieldStr}"');
			sbuf.add(") "); // close
			if (hasParams) {
				var params = [for (_p in func.sig.paramTypes) _p.toString()].join(" ");
				sbuf.add("("); // open
				sbuf.add('param ${params}');
				sbuf.add(")"); // close
			}
			if (hasReturn) {
				var returns = [for (_r in func.sig.returnTypes) _r.toString()].join(" ");
				sbuf.add("("); // open
				sbuf.add('result ${returns}');
				sbuf.add(")"); // close
			}
			var d = new Disassembly(func, func.body.module);
					
			sbuf.add('${[for(c in d.code) '(${c.op.name} ${c.immediates.join(" ")})'].join(" ")}');
			sbuf.add(")"); // close
		}
	}

	static function getGlobals(indexSpace:Array<GlobalEntry>, sbuf:StringBuf, isExport:Bool = false, export:ExportEntry = null) {
		for (global in indexSpace) {
			var index = indexSpace.indexOf(global);
			var buf = new BytesInput(global.init);
			var value:Dynamic = null;
			var type = global.type.type;
			switch type {
				case ValueTypeI32:
					value = buf.readInt32();
				case ValueTypeI64:
					value = buf.readInt32();
				case ValueTypeF32:
					value = buf.readFloat();
				case ValueTypeF64:
					value = buf.readDouble();
			}
			sbuf.add('(global ;$index ');
			if (isExport) {
				sbuf.add('(export "${export.fieldStr}") ');
			}
			if (global.type.mutable) {
				sbuf.add('(mut ${type}) ');
			}
			sbuf.add('(${type}.const ${value}))');
			sbuf.add('\n');
		}
		sbuf.add('\n');
	}
}
