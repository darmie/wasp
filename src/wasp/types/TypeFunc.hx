package wasp.types;

import haxe.io.*;

/**
 * represents the value type of a function
 */
abstract TypeFunc(Int) from Int to Int {
    public inline function new() {
        this = 0x60;
    }  

    public function toWasm(w:BytesOutput) {
        w.writeByte(this);
    }  

    public inline function fromWasm(r:BytesInput) {
        var v = r.readByte();
        this = v;
    }
}