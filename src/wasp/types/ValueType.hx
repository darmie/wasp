package wasp.types;

enum abstract ValueType(Int) from Int to Int {
	public inline function new(){this = 0;}

	var ValueTypeI32 = 0x7f;
	var ValueTypeI64 = 0x7e;
	var ValueTypeF32 = 0x7d;
	var ValueTypeF64 = 0x7c;
	public static var stringMap:Map<ValueType, String> = [
		ValueTypeI32 => "i32",
		ValueTypeI64 => "i64",
		ValueTypeF32 => "f32",
		ValueTypeF64 => "f64"
	];

	@:to public function toString():String {
		return '${stringMap.get(this)}';
	}

	public inline function fromWasm(input:haxe.io.Input) {
		var v = input.readByte();
		this = v;
	}

	public inline function toWasm(output:haxe.io.Output) {
		output.writeByte(this);
	}
}
