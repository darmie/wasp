package wasp.io;

import haxe.io.*;
import binary128.internal.Leb128;

class Read {

    public static function bytes(r:BytesInput, n:Int):Bytes {
        if(n == 0){
            return null;
        }
        var b = Bytes.alloc(n);
        r.readBytes(b, 0, n);
        // var limited = new LimitReader(r, n);
        // var buf = new BytesOutput();
        // buf.writeInput(limited);
        var num = b.length;
        if(num == n){
            return b;
        }
        throw Eof;
    }

    public static function byte(r:BytesInput) {
       return r.read(1).get(0);
    }

    public static function bytesUint(r:BytesInput):Bytes {
        var n = Leb128.readUint32(r);
        return bytes(r, n);
    }

    public static function UTF8String(r:BytesInput, n) {
        var _bytes = bytes(r, n);
        if(_bytes == null) return "";
        
        if(!UnicodeString.validate(_bytes, UTF8)){
            throw "wasm: invalid utf-8 string";
        }
        var s = _bytes.toString();
        return s;
    }

    public static function UTF8StringUint(r:BytesInput) {
        var n = Leb128.readUint32(r);
        return UTF8String(r, n);
    }

    public static function U32(r:BytesInput) {
        var buf = Bytes.alloc(4);
        r.readFullBytes(buf, 0, 4);
        return LittleEndian.Uint32(buf);
    }

    public static function U64(r:BytesInput) {
        var buf = Bytes.alloc(8);
        r.readFullBytes(buf, 0, 8);
        #if !cs
        return LittleEndian.Uint64(buf);
        #else 
        return untyped __cs__('System.BitConverter.ToUInt64({0}, 0)', buf.getData());
        #end
    }
}