package wasp.types;

import haxe.io.*;

class Memory implements Marshaller {
    public var limits:ResizableLimits;

    public function new() {
        
    }

    public function toWasm(w:BytesOutput) {
        limits.toWasm(w);
    }

    public function fromWasm(r:BytesInput) {
        limits.fromWasm(r);
    }
}