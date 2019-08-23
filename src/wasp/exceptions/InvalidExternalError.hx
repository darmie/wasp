package wasp.exceptions;

abstract InvalidExternalError(String) from String to String {
    public inline function new(i:Int) {
        this = 'wasm: invalid external_kind value $i';
    }
}