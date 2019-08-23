package wasp.exceptions;

abstract ExportNotFoundErr(String) from String to String {
    public inline function new(fieldName:String, moduleName:String) {
        this = 'wasm: couldn\'t find export with name $fieldName in module $moduleName';
    }
}