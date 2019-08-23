package wasp.types;

import binary128.internal.Leb128;
import haxe.io.*;

class LocalEntry {

    /**
     *  The total number of local variables of the given Type used in the function body
     */
    public var count:Int;

    /**
     * The type of value stored by the variable
     */
    public var type:ValueType;

    public function new() {
        
    }

    public function toWasm(w:BytesOutput):Void {
        Leb128.writeUint32(w, count);
        type.toWasm(w);
    }

    public function fromWasm(r:BytesInput):Void {
        this.count = Leb128.readUint32(r);

        this.type.fromWasm(r);
    }
}