package wasp.sections;

import binary128.internal.Leb128;
import haxe.io.BytesOutput;
import haxe.io.BytesInput;
import wasp.types.Memory;

class Memories extends RawSection {
    public var entries:Array<Memory>;

    override function sectionID():SectionID {
        return SectionIDMemory;
    }

    override function readPayload(r:BytesInput) {
        var count = Leb128.readUint32(r);
        for(i in 0...count){
            var entry = new Memory();
            entry.fromWasm(r);
            entries.push(entry);
        }
    }

    override function writePayload(w:BytesOutput) {
        Leb128.writeUint32(w, entries.length);
        for(e in entries){
            e.toWasm(w);
        }
    }
}