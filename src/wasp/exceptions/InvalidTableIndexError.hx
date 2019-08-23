package wasp.exceptions;

abstract InvalidTableIndexError(Int) from Int to Int {
    public inline function new(i){
        this = i;
    }
    public  inline function toString():String {
        return 'wasm: Invalid table to table index space: $this';
    }
}