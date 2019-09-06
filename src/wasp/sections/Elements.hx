package wasp.sections;

import haxe.io.*;

import binary128.internal.Leb128;
import wasp.types.ElementSegment;

/**
 * describes the initial contents of a table's elements.
 */
class Elements extends RawSection {
    public var entries:Array<ElementSegment>;


    override function sectionID():SectionID {
        return SectionIDElement;
    }

    override function readPayload(r:BytesInput) {
        var count = Leb128.readUint32(r);
        for(i in 0...cast(count, Int)){
            var segment = new ElementSegment();
            segment.fromWasm(r);
            entries.push(segment);
        }
    }

    override function writePayload(w:BytesOutput) {
        Leb128.writeUint32(w, entries.length);
        for(e in entries){
            e.toWasm(w);
        }
    }
}