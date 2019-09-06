package wasp.sections;

import haxe.io.BytesOutput;
import haxe.io.BytesInput;
import binary128.internal.Leb128;
import wasp.types.Table;

class Tables extends RawSection {
    public var entries:Array<Table>;


    override function sectionID():SectionID {
        return SectionIDTable;
    }

    override function readPayload(r:BytesInput) {
        var count = Leb128.readUint32(r);
        entries = [];

        for(i in 0...cast(count, Int)){
            var entry = new Table();
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