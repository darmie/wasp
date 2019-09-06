package wasp.io;

import haxe.io.*;
import haxe.Int64;

class ReadPos  extends  BytesInput {
    public var curPos:I64;

    public function new(b:BytesInput) {
        // var buf = new BytesOutput();
        // buf.writeInput(b);
        super(b.readAll());
    }

    override public function readBytes(p:Bytes, pos:Int, len:Int):Int {
        super.readFullBytes(p, 0, p.length);
        curPos += p.length;
        return p.length;
    }

    override public function readByte():Int {
        // var p = Bytes.alloc(1);
        var n = super.readByte();
        curPos += n;
        return n;
    }
}