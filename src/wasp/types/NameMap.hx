package wasp.types;

import haxe.io.*;
import wasp.io.*;
import binary128.internal.Leb128;


/**
 * maps an index of the entry to a name.
 */

@:forward(exists)
abstract NameMap(Map<U32, String>) to  Map<U32, String>{
    public inline function new(){
        this = new Map<U32, String>();
    }

    @:arrayAccess public inline function get(key:U32):String {
        return this.get(key);
    }

    @:arrayAccess public inline function set(key:U32, value:String):Void {
        this.set(key, value);
    }
    public function toWasm(w:BytesOutput):Void {
        var keys = [];
        for(k=>_ in this){
            keys.push(k);
        }

        keys.sort((i, j)->{
            return -1;
        });

        for(k in keys){
            var name = this.get(k);
            Leb128.writeUint32(w, k);
            var b = Bytes.ofString(name);
            Encode.writeBytesUint(w, b);
        }
    }

    public function fromWasm(r:BytesInput):Void {
        var size = Leb128.readUint32(r);
        for(i in 0...cast(size, Int)){
            var ind = Leb128.readUint32(r);
            var name = Read.UTF8StringUint(r);
            this.set(ind, name);
        }
    }
}