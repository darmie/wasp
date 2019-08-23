package wasp.exceptions;

import wasp.types.External;

abstract KindMismatchError(String) from String to String {
    public inline function new(moduleName:String, fieldName:String, import_:External, export:External) {
        this = 'wasm: mismatching import and export external kind values for $fieldName.$moduleName ($import_, $export)';
    }
}