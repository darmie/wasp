package wasp.imports;

import binary128.internal.Leb128;
import wasp.types.External;
import wasp.types.ImportType;
import haxe.io.*;

class FuncImport implements ImportType {
    public var type:Int;
    public function kind():External{
        return ExternalFunction;
    }
    public function isImport():Void {}

    public function fromWasm(r:BytesInput) {
        
    }

    public inline function toWasm(w:BytesOutput) {
        Leb128.writeUint32(w, type);
    }

}