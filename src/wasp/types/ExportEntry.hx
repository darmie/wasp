package wasp.types;

import haxe.io.*;

import wasp.io.*;

import binary128.internal.Leb128;

class ExportEntry implements Marshaller {
    public var fieldStr:String;
	public var kind:External;
	public var index:Int;

	public function new() {
	}

	public function fromWasm(r:BytesInput) {
		fieldStr = Read.UTF8StringUint(r);
		kind.fromWasm(r);
		index = Leb128.readUint32(r);
	}

	public function toWasm(w:BytesOutput) {
		Encode.writeBytesUint(w, Bytes.ofString(fieldStr));
		kind.toWasm(w);
		Leb128.writeUint32(w, index);
	}
}