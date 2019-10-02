package wasp.imports;

import binary128.internal.Leb128;
import wasp.types.*;
import haxe.io.*;
import wasp.io.*;
import wasp.exceptions.*;
import wasp.io.Read.*;
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
        moduleName = UTF8StringUint(r);
        fieldName = UTF8StringUint(r);

        var kind:External = new External();
        kind.fromWasm(r);

        switch kind {
            case ExternalFunction: {
                var t:U32 = Leb128.readUint32(r);
                type = new FuncImport();
                cast(type, FuncImport).type = t;
            }
            case ExternalTable: {
                var table:Table = new Table();
                table.fromWasm(r);
                type = new TableImport();
                cast(type, TableImport).type = table;
            }
            case ExternalMemory:{
                var mem:Memory = new Memory();
                mem.fromWasm(r);
                type = new MemoryImport();
                cast(type, MemoryImport).type = mem;
            }
            case ExternalGlobal:{
                var gl:GlobalVar = new GlobalVar();
                gl.fromWasm(r);
                type = new GlobalVarImport();
                cast(type, GlobalVarImport).type = gl;
            }
            default: throw new InvalidExternalError(kind);
        }
    }

    public static function writeImportEntry(w:BytesOutput, i:ImportEntry) {
        Encode.writeBytesUint(w, Bytes.ofString(i.moduleName));
        Encode.writeBytesUint(w, Bytes.ofString(i.fieldName));
        
        i.type.kind().toWasm(w);
        i.type.toWasm(w);
    }
}
