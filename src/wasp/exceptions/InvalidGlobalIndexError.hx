package wasp.exceptions;

abstract InvalidGlobalIndexError(Int) {
    public inline function new(i:Int) {
        this = i;
    }

    public inline function toString() {
       return 'wasm: Invalid index to global index space: ${StringTools.hex(this)}';
    }
}