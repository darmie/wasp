package wasp.types;

import wasp.io.*;
import haxe.io.*;

enum abstract ElemType(Int) from Int to Int {
    /**
     * descibres an any_func value
     */
    var ElemTypeAnyFunc = 0x70;


    public  inline function toString() {
        if(this == ElemTypeAnyFunc){
            return "anyfunc";
        } 

        return "<unknown elem_type>";
    }

    public inline function fromWasm(r:BytesInput){
       var b =  Read.byte(r);
       if(b != ElemTypeAnyFunc){
           throw 'wasm: unsupported elem type:$b';
       }
        this = b;
    }

    public function toWasm(w:BytesOutput) {
        return Encode.writeU32(w, this);
    }
} 