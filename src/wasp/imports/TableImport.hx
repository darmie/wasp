package wasp.imports;

import wasp.types.*;
import haxe.io.*;


class TableImport implements ImportType {
    public var type:Table;

    public function new() {
        
    }

    public function kind():External{
        return ExternalTable;
    }
    public function isImport():Void {}

    public function fromWasm(r:BytesInput) {
        
    }

    public inline function toWasm(w:BytesOutput) {
        type.toWasm(w);
    }
}