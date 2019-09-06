package;

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
				for (f in m.functionIndexSpace) {
					
					// new Disassembly(f, m);
				}
			}
		} catch (e:Dynamic) {
			throw e;
		}
	}
}
