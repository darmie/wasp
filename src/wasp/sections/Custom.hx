package wasp.sections;

import haxe.io.*;
import wasp.io.*;


class Custom extends RawSection {
    public var name:String;
    public var data:Bytes;

    override function sectionID():SectionID {
        return SectionIDCustom;
    }

    override function readPayload(r:BytesInput) {
        // super.readPayload(r);
        name = Read.UTF8StringUint(r);
        data = r.readAll();
    }

    override function writePayload(w:BytesOutput) {
        Encode.writeBytesUint(w, Bytes.ofString(name));
        w.write(data);
    }
}