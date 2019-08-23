package wasp.exceptions;

abstract ErrorEmptyInitExpr(String) {
    public inline function new() {
        this = "wasm: Initializer expression produces no value";
    }
}