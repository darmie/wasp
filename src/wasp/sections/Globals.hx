package wasp.sections;

import haxe.io.BytesOutput;
import haxe.io.BytesInput;
import binary128.internal.Leb128;
import wasp.types.GlobalEntry;

class Globals extends RawSection {
    public var globals:Array<GlobalEntry>;

    override function sectionID():SectionID {
        return SectionIDGlobal;
    }

    override function readPayload(r:BytesInput) {
        var count = Leb128.readUint32(r);
        globals = [];

        for(i in 0...cast(count, Int)){
            var global = new GlobalEntry();
            global.fromWasm(r);
            globals.push(global);
        }
    }

    override function writePayload(w:BytesOutput) {
        Leb128.writeUint32(w, globals.length);

        for(g in globals){
            g.toWasm(w);
        }
    }
}