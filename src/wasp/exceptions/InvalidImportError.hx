package wasp.exceptions;
import haxe.io.BytesOutput;
import binary128.internal.Leb128;

abstract InvalidImportError(String) from String to String {
    public inline function new(moduleName:String, fieldName:String, typedIndex:Int) {
        var buf = new BytesOutput();
        Leb128.writeUint32(buf, typedIndex);
        var _typeIndex = buf.getBytes().toHex();
        this = 'wasm: invalid signature for import 0x$_typeIndex with name "$fieldName" in module $moduleName';
    }
}