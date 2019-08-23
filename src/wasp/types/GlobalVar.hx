package wasp.types;

import haxe.io.*;

class GlobalVar implements Marshaller {
    public var type:ValueType;
    public var mutable:Bool;


    public function new() {
        
    }

    public function toWasm(w:BytesOutput) {
        type.toWasm(w);
        var m = 0;
        if (mutable){
            m = 1;
        }
        return w.writeByte(m);
    }

    public function fromWasm(r:BytesInput) {
        type.fromWasm(r);
        var m = r.readByte();

        if(m != 0x00 && m != 0x01){
            throw "wasm: invalid global mutable flag";
        }

        mutable = m == 0x01;
    }
}