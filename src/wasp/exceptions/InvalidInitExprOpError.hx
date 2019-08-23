package wasp.exceptions;

abstract InvalidInitExprOpError(Int) {
    public inline function new(i:Int) {
        this = i;
    }

    public inline function toString() {
       return 'wasm: Invalid opcode in initializer expression: ${StringTools.hex(this)}';
    }
}