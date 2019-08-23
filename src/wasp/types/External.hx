package wasp.types;

import haxe.io.BytesBuffer;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;

enum abstract External(Int) from Int to Int {
	var ExternalFunction = 0;
	var ExternalTable = 1;
	var ExternalMemory = 2;
	var ExternalGlobal = 3;

	public function toString():String {
		return switch (this) {
			case ExternalFunction:
				"function";
			case ExternalTable:
				"table";
			case ExternalMemory:
				"memory";
			case ExternalGlobal:
				"global";
			default:
				"<unknown external_kind>";
		}
	}

	public function toWasm(w:BytesOutput) {
		var buf = new BytesBuffer();
		buf.addByte(this);
		w.write(buf.getBytes());
	}

	public inline function fromWasm(r:BytesInput) {
		var bytes = r.read(1);
		this = bytes.get(0);
	}
}
