package wasp.sections;

import binary128.internal.Leb128;
import wasp.imports.ImportEntry;
import haxe.io.*;

class Imports extends RawSection {
    public var entries:Array<ImportEntry>;

    override function sectionID():SectionID {
        return SectionIDImport;
    }

    override function readPayload(r:BytesInput) {
        var count = Leb128.readUint32(r);
        entries = [];
        for(i in 0...count){
            var entry = new ImportEntry();
            entry.fromWasm(r);
            entries.push(entry);
        }
    }

    override function writePayload(w:BytesOutput) {
        Leb128.writeUint32(w, entries.length);
        for(e in entries){

        }
    }
}