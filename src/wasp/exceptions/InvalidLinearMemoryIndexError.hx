package wasp.exceptions;

abstract InvalidLinearMemoryIndexError(Int) from Int to Int {
    public inline function new(i){
        this = i;
    }

    public inline function toSting() {
        return 'wasm: Invalid linear memory index: $this';
    }
}