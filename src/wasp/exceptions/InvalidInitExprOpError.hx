package wasp.exceptions;

abstract InvalidInitExprOpError(String) {
    public inline function new(i:Int) {
        this = 'wasm: Invalid opcode in initializer expression: 0x${StringTools.hex(i)}';
    }
}