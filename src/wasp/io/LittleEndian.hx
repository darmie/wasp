package wasp.io;

import haxe.io.BytesOutput;
import haxe.io.BytesInput;
import haxe.io.Bytes;

class LittleEndian {

	public static function Uint16(b:Bytes):Int {
		return b.get(0) | b.get(1) << 8;
	}

	public static function PutUint16(b:Bytes, v:Int) {
		b.set(0, v);
		b.set(1, v >> 8);
	}
	public static function Uint32(b:Bytes):Int {
		return b.get(0) | b.get(1) << 8 | b.get(2) << 16 | b.get(3) << 24;
	}

	public static function PutUint32(b:BytesOutput, v:Int) {
		b.writeByte(v >> 24);
		b.writeByte(v >> 16);
		b.writeByte(v >> 8);
		b.writeByte(v);
	}

	public static function Uint64(b:Bytes):Int {
		return b.get(0) | b.get(1) << 8 | b.get(2) << 16 | b.get(3) << 24 | b.get(4) << 32 | b.get(5) << 40 | b.get(6) << 48 | b.get(7) << 56;
	}

	public static function PutUint64(b:BytesOutput, v:Int) {
		b.writeByte(v);
		b.writeByte(v >> 8);
		b.writeByte(v >> 16);
		b.writeByte(v >> 24);
		b.writeByte(v >> 32);
		b.writeByte(v >> 40);
		b.writeByte(v >> 48);
		b.writeByte(v >> 56);
	}
}
