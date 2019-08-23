package wasp.imports;

import wasp.types.*;
import haxe.io.*;
import wasp.io.*;


/**
 * ImportEntry describes an import statement in a Wasm module.
 */
class ImportEntry implements Marshaller  {
    public var moduleName:String;
    public var fieldName:String;

    /**
     * If Kind is Function, Type is a FuncImport containing the type index of the function signature
     * 
     * If Kind is Table, Type is a TableImport containing the type of the imported table
     * 
     * If Kind is Memory, Type is a MemoryImport containing the type of the imported memory
     * 
     * If the Kind is Global, Type is a GlobalVarImport
     */
    public var type:ImportType;

    public function new() {
        
    }

    public function toWasm(w:BytesOutput) {
        
    }

    public function fromWasm(r:BytesInput) {
        
    }

    public static function writeImportEntry(w:BytesOutput, i:ImportEntry) {
        Encode.writeBytesUint(w, Bytes.ofString(i.moduleName));
        Encode.writeBytesUint(w, Bytes.ofString(i.fieldName));
        
        i.type.kind().toWasm(w);
        i.type.toWasm(w);
    }
}
