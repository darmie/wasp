package wasp.io;

import haxe.io.*;
import haxe.Int64;

class ReadPos  extends  BytesInput {
    public var curPos:Int64 = 0;

    public function new(b:BytesInput) {
       super(b.readAll());
    }

    override public function readBytes(p:Bytes, pos:Int, len:Int):Int {
        var n = super.readBytes(p, 0, p.length);
        curPos += Int64.ofInt(n);
        return n;
    }

    override public function readByte():Int {
        var p = Bytes.alloc(1);
        var n = super.readBytes(p, 0, p.length);
        curPos += Int64.ofInt(n);
        return p.get(0);
    }
}