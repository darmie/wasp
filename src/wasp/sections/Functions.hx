package wasp.sections;

import haxe.io.BytesOutput;
import haxe.io.BytesInput;
import binary128.internal.Leb128;

class Functions extends RawSection {
    /**
     * Sequences of indices into (FunctionSignatues).Entries
     */
    public var types:Array<Int>;

    override function sectionID():SectionID {
        return SectionIDFunction;
    }

    override function readPayload(r:BytesInput) {
        var count = Leb128.readUint32(r);
        for(i in 0...count){
            var type = Leb128.readUint32(r);
            types.push(type);
        }
    }

    override function writePayload(w:BytesOutput) {
        Leb128.writeUint32(w, types.length);
        for(type in types){
            Leb128.writeUint32(w, type);
        }
    }
}