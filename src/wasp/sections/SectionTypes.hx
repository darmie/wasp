package wasp.sections;

import wasp.types.*;
import haxe.io.*;
import binary128.internal.Leb128;

class SectionTypes extends RawSection {
    public var entries:Array<FunctionSig>;

    override function sectionID():SectionID {
        return SectionIDType;
    }

    override function readPayload(r:BytesInput) {
        var count = Leb128.readUint32(r);
        entries = [];

        for(i in 0...count){
            var sig = new FunctionSig();
            sig.fromWasm(r);
            entries.push(sig);
        }
    }

    override function writePayload(w:BytesOutput) {
       Leb128.writeUint32(w, entries.length);
       for(f in entries){
           f.toWasm(w);
       }
    }
}