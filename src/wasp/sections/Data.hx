package wasp.sections;

import haxe.io.*;
import wasp.types.DataSegment;

import binary128.internal.Leb128;

class Data extends RawSection{
    public var entries:Array<DataSegment>;

    override function readPayload(r:BytesInput) {
        // super.readPayload(r);
        var count = Leb128.readUint32(r);
        entries = [];
        for(i in 0...cast(count, Int)){
            var entry = new DataSegment();
            entry.fromWasm(r);
            entries.push(entry);
        }
    }

    override function writePayload(w:BytesOutput) {
        // super.writePayload(w);
        Leb128.writeUint32(w, entries.length);
        for(e in entries){
            e.toWasm(w);
        }
    }
}