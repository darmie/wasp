package wasp.sections;

import wasp.types.*;
import wasp.io.*;
import haxe.io.*;

/**
 * The name of a module.
 */
class ModuleName implements NameSubSection {
    
    public var name:String;

    public function new() {
        
    }

    public function toWasm(w:BytesOutput):Void {
        var n = Bytes.ofString(name);
        Encode.writeBytesUint(w, n);
    }

    public function fromWasm(r:BytesInput):Void {
        name = Read.UTF8StringUint(r);
    }
}