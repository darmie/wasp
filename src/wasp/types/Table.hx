package wasp.types;

import haxe.io.*;

/**
 * describes a table in a Wasm module.
 */
class Table implements Marshaller {

    // The type of elements
    public var elementType:ElemType;
    public var limits:ResizableLimits;

    public function new() {
        
    }

    public function toWasm(w:BytesOutput) {
        elementType.toWasm(w);
        limits.toWasm(w);
    }

    public function fromWasm(r:BytesInput) {
        elementType.fromWasm(r);
        limits.fromWasm(r);

    }
}