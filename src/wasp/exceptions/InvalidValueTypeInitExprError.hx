package wasp.exceptions;

import Type.ValueType;

typedef InvalidValueTypeInitExprErrorT = {
    wanted:ValueType,
    got:ValueType
}


abstract InvalidValueTypeInitExprError(InvalidValueTypeInitExprErrorT) from InvalidValueTypeInitExprErrorT to InvalidValueTypeInitExprErrorT {
    public inline function new(wanted:ValueType, got:ValueType) {
        this = {
            wanted: wanted,
            got: got
        };
    }

    public inline function toString():String {
       return 'wasm: Wanted initializer expression to return ${this.wanted} value, got ${this.got}';
    }
}