package wasp;

import haxe.io.*;
import wasp.io.*;
import wasp.types.*;
import wasp.exceptions.*;
import binary128.internal.Leb128;

import wasp.Module;
import wasp.operators.Op;
import wasp.types.ValueType;
import wasp.types.BlockType;

class Global {
    public static inline var Magic:Int = 0x6d736100;

    public static var ops:Array<Op> = [];

    public static var internalOpcodes:Map<Int, Bool> = [
        NativeExec => true
    ];

    public static var NativeExec = Op.init(0xfe, "nativeExec", [ValueTypeI64], cast BlockTypeEmpty);

    // to avoid memory attack
	private static inline var maxInitialCap = 10 * 1024;
	public static function getInitialCap(count:Int) {

		if (count > maxInitialCap) {
			return maxInitialCap;
		}
		return count;
	}

	public static inline var CustomSectionName = "name";

	public static inline var i32Const = 0x41;
	public static inline var i64Const = 0x42;
	public static inline var f32Const = 0x43;
	public static inline var f64Const = 0x44;
	public static inline var getGlobal = 0x23;
	public static inline var end = 0x0b;



    public static function readInitExpr(r:BytesInput):Bytes {
		var b = Bytes.alloc(1);
		var buf = new BytesOutput();
		r = new TeeReader(r, buf);
		var recur = function():Bytes {
			return null;
		};

		recur = () -> {
			while (true) {
				r.readFullBytes(b, 0, b.length);
				switch b.get(0) {
					case i32Const: {
							Leb128.readUint32(r);
						}
					case i64Const: {
							Leb128.readUint64(r);
						}
					case f32Const: {
							Read.U32(r);
						}
					case f64Const: {
							Read.U64(r);
						}
					case getGlobal: {
							Leb128.readUint32(r);
						}
					case end: {
							return recur();
						}
					default: {
							throw new InvalidInitExprOpError(b.get(0));
						}
				}
			}
			if (buf.length == 0) {
				throw new ErrorEmptyInitExpr();
			}

			return buf.getBytes();
		}
		return recur();
	}

	/**
	 * executes an initializer expression and returns a value
	 * which can either be int32, int64, float32 or float64.
	 * It throws an error if the expression is invalid, and nil when the expression
	 * yields no value.
	 * @param expr
	 * @return Dynamic
	 */
	public static function execInitExpr(module:Module, expr:Bytes):Dynamic {
		var stack = [];
		var lastVal:ValueType = null;
		var r = new BytesInput(expr);

		if (r.length == 0) {
			throw new ErrorEmptyInitExpr();
		}
		while (true) {
			var b = r.readByte();
			var _break = false;
			switch b {
				case i32Const:
					{
						var i = Leb128.readInt32(r);
						stack.push(i);
						lastVal = ValueTypeI32;
					}
				case i64Const:
					{
						var i = Leb128.readInt64(r);
						stack.push(i);
						lastVal = ValueTypeI64;
					}
				case f32Const:
					{
						var i = Read.U32(r);
						stack.push(i);
						lastVal = ValueTypeF32;
					}
				case f64Const:
					{
						var i = Read.U64(r);
						stack.push(i);
						lastVal = ValueTypeF64;
					}
				case getGlobal:
					{
						var i = Leb128.readInt32(r);
						var globalVar = module.getGlobal(cast i);
						if (globalVar == null) {
							throw new InvalidGlobalIndexError(cast i);
						}
						lastVal = globalVar.type.type;
					}
				case end:
					{
						_break = true;
						break;
					}
				default:
					{
						throw new InvalidInitExprOpError(b);
					}
			}
			if (_break) {
				break;
			}
		}
		if (stack.length == 0) {
			return null;
		}
		var v = stack[stack.length - 1];
		switch lastVal {
			case ValueTypeI32:
				{
					return cast(v, haxe.Int32);
				}
			case ValueTypeI64:
				{
					return haxe.Int64.ofInt(v);
				}
			case ValueTypeF32 | ValueTypeF64:
				{
					return cast(v, Float);
				}
			default:
				throw 'Invalid value type produced by initializer expression: $lastVal';
		}
		return null;
	}
}