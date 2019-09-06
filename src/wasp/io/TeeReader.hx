package wasp.io;

import haxe.io.*;
class TeeReader extends BytesInput {
	var writer:Output;

	public function new(r:Input, w:Output) {
        super(r.readAll());
		writer = w;
	}

	override public function readBytes(p:Bytes, pos:Int, len:Int):Int {
		var n = super.readBytes(p, pos, len);
		if (n > 0) {
			n = writer.writeBytes(p, 0, n);
		}
		return n;
	}
}