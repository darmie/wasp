package wasp.types;

import binary128.internal.Leb128;
import haxe.io.*;
import wasp.io.*;
import wasp.Global.*;

/**
 * Describes the signature of a declared function in a WASM module
 */
class FunctionSig implements Marshaller {
    /**
     * value for the 'func` type constructor
     */
    public var form:Int;

    /**
     * The parameter types of the function
     */
    public var paramTypes:Array<ValueType>;

    public var returnTypes:Array<ValueType>;

    public function new() {
        
    }
    public function toString() {
        return '<func ${paramTypes} -> ${returnTypes}>';
    }


    public function toWasm(w:BytesOutput) {
        w.writeByte(form);
        Leb128.writeUint32(w, paramTypes.length);
        for(p in paramTypes){
            p.toWasm(w);
        }

        Leb128.writeUint32(w, returnTypes.length);
        for(r in returnTypes){
            r.toWasm(w);
        }
          
    }

    public function fromWasm(r:BytesInput) {
        var form = Read.byte(r);
        var buf = new BytesBuffer();
        buf.addByte(form);
        if(form != 0x60){
            throw 'wasm: unknown function form: 0x${buf.getBytes().toHex()}';
        }
        
        this.form = form;
        
        var paramCount = Leb128.readUint32(r);
        paramTypes = [];
        for(i in 0...getInitialCap(cast(paramCount, Int))){
            var v = new ValueType();
            v.fromWasm(r);
            paramTypes.push(v);
        }

        var returnCount = Leb128.readUint32(r);
        returnTypes = [];
        for(i in 0...getInitialCap(cast(returnCount, Int))){
            var v = new ValueType();
            v.fromWasm(r);
            returnTypes.push(v);
        }
        
    }
}