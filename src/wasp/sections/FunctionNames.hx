package wasp.sections;

import haxe.io.*;
import wasp.types.*;

/**
 * Set of names for functions.
 */
class FunctionNames implements NameSubSection {
    public var names:NameMap;
    public function new() {
        
    }

    public function toWasm(w:BytesOutput):Void {
       names.toWasm(w);
    }

    public function fromWasm(r:BytesInput):Void {
        names = new NameMap();
        names.fromWasm(r);
    }
}