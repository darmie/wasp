package wasp.io;

import binary128.internal.Leb128;
import haxe.io.*;
import wasp.Global.*;
import wasp.Module;

class Encode {
    public static var currentVersion = 0x01;
    public static function module(w:BytesOutput, m:Module) {
        writeU32(w, Magic);
        writeU32(w, currentVersion);
        var sections = m.sections;
        var buf = new BytesOutput();
        
        for(s in sections){
            Leb128.writeUint32(w, Std.int(s.sectionID()));

            s.writePayload(buf);
            Leb128.writeUint32(w, buf.length);
            w.write(buf.getBytes());
        }
    }

    public static function writeBytesUint(w:BytesOutput, p:Bytes) {
        Leb128.writeUint32(w, p.length);
        w.write(p);
    }

    public static function writeStringUint(w:BytesOutput, s:String) {
        writeBytesUint(w, Bytes.ofString(s));
    }

    public static function writeU32(w:BytesOutput, n:U32) {
        LittleEndian.PutUint32(w, n);
    }

    public static function writeU64(w:BytesOutput, n) {
        LittleEndian.PutUint64(w, n);
    }
}