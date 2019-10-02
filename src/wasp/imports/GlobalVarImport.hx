package wasp.imports;

import wasp.types.*;
import haxe.io.*;


class GlobalVarImport implements ImportType {

    public var type:GlobalVar;

    public function new() {
        
    }
    public function kind():External{
        return ExternalGlobal;
    }
    public function isImport():Void {}

    public function fromWasm(r:BytesInput) {
        
    }

    public inline function toWasm(w:BytesOutput) {
        type.toWasm(w);
    }
}