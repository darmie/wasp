package wasp.imports;

import wasp.types.*;
import haxe.io.*;


class MemoryImport implements ImportType {

    public var type:Memory;

    public function new() {
        
    }
    public function kind():External{
        return ExternalMemory;
    }
    public function isImport():Void {}

    public function fromWasm(r:BytesInput) {
        
    }

    public inline function toWasm(w:BytesOutput) {
        type.toWasm(w);
    }
}