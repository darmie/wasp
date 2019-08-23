package wasp.sections;

import wasp.types.*;
import haxe.io.*;
import binary128.internal.Leb128;

/**
 * set of local variable names for functions.
 */
class LocalNames implements NameSubSection {

    /**
     * maps a function index to a set of variable names.
     */
    public var funcs:Map<Int, NameMap>;
    public function new() {
        
    }

    public function toWasm(w:BytesOutput):Void {
        var keys = [];
        for(k=>_ in funcs){
            keys.push(k);
        }
        keys.sort((i, j)->{
            return -1;
        });

        for(k in keys){
            var m = funcs.get(k);
            Leb128.writeUint32(w, k);
            m.toWasm(w);
        }
    }

    public function fromWasm(r:BytesInput):Void {
        funcs = new Map<Int, NameMap>();
        var size = Leb128.readUint32(r);
        for(i in 0...size){
            var ind = Leb128.readUint32(r);
            var m = new NameMap();
            m.fromWasm(r);
            funcs.set(ind, m);
        }
    }
}