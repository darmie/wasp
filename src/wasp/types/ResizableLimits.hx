package wasp.types;

import haxe.io.*;
import binary128.internal.Leb128;


class ResizableLimits implements Marshaller {

    /**
     * 1 if the Maximum field is valid, 0 otherwise
     */
    public var flags:Int;

    /**
     * initial length (in units of table elements or wasm pages)
     */
    public var initial:U32;

    /**
     * If flags is 1, it describes the maximum size of the table or memory
     */
    public var maximum:U32;

    public function new(initial:Int) {
        
    }

    public function toWasm(w:BytesOutput) {
        var f = flags;
        if(f != 0 && f != -1){
            throw "wasm: invalid limit flag";
        }

        var buf = new BytesBuffer();
        buf.addByte(f);
        w.write(buf.getBytes());

        Leb128.writeUint32(w, initial);
        Leb128.writeUint32(w, maximum);
    }

    public function fromWasm(r:BytesInput) {
        var f = r.readByte();
        if(f != 0 && f != -1){
            throw "wasm: invalid limit flag";
        }

        flags = f;

        initial = Leb128.readUint32(r);

        if(flags&0x1 != 0){
            maximum = Leb128.readUint32(r);
        }
    }

}