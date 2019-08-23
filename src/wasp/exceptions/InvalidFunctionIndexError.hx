package wasp.exceptions;

abstract InvalidFunctionIndexError(Int) from Int to Int {
    public inline function new(i){
        this = i;
    }
    public  inline function toString():String {
        return 'wasm: Invalid function to table index space: $this';
    }
}