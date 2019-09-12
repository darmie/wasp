package wasp.types;

import wasp.Module;
import haxe.io.*;
import binary128.internal.Leb128;
import wasp.io.*;
import wasp.Global.*;

class FunctionBody {
    public var module:Module;
    public var locals:Array<LocalEntry>;

    public var code:Bytes;

    public function new(module:Module) {
        this.module = module;
    }

    public function fromWasm(r:BytesInput) {
        var bodySize = Leb128.readUint32(r);
        var body = Read.bytes(r, bodySize);
        var bytesReader = new BytesInput(body);

        var localCount = Leb128.readUint32(bytesReader);
        locals = [];
        // locals.resize(Constants.getInitialCap(localCount));

        for(i in 0...cast(localCount, Int)){
            var local:LocalEntry = new LocalEntry();
            local.fromWasm(bytesReader);
            locals.push(local);
        }

        hex.log.HexLog.info('bodySize: $bodySize, localCount: ${localCount}\n');
        var code = bytesReader.readAll();
        hex.log.HexLog.info('Read ${code.length} bytes for function body');

        if(code.get(code.length - 1) != end){
            throw "Function body does not end with 0x0b (end)";
        }

        this.code = code.sub(0, code.length - 1);
    }

    public function toWasm(w:BytesOutput) {
        var body = new BytesOutput();
        Leb128.writeUint32(body, locals.length);

        for(l in locals){
            l.toWasm(body);
        }
        body.write(code);
        body.writeByte(end);
        Encode.writeBytesUint(w, body.getBytes());
    }
}