package wasp.sections;

import haxe.io.BytesOutput;
import haxe.io.BytesInput;
import binary128.internal.Leb128;
/**
 * represents the start function section.
 */
class StartFunction extends RawSection {
    public var index:Int;

    override function sectionID():SectionID {
        return SectionIDStart;
    }

    override function readPayload(r:BytesInput) {
        index = Leb128.readUint32(r);
    }

    override function writePayload(w:BytesOutput) {
        Leb128.writeUint32(w, index);
    }
}