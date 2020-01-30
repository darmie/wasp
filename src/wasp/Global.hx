package wasp;

import haxe.Int64;
import haxe.ds.Vector;
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
	public static var Version:U32 = 0x1;

	public static var Magic:U32 = 0x6d736100;

	public static var ops:Vector<Op> = new Vector(256);

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

	// public static function __init__() {
	// 	for(op in ops){
	// 		op = new Op();
	// 	}
	// }

	public static function readInitExpr(r:BytesInput):Bytes {
		var b = Bytes.alloc(1);
		var buf = new BytesOutput();

		while (true) {
			// r.readBytes(b, 0, 1);
			var op = r.readByte();

			switch op {
				case i32Const:
					{
						var v:Int = Leb128.readInt32(r);
						buf.writeByte(op);
						buf.writeInt32(v);
					}
				case i64Const:
					{
						var v = Leb128.readInt64(r);
						buf.writeByte(op);
						buf.writeDouble(FPHelper.i64ToDouble(v.low, v.high));
					}
				case f32Const:
					{
						var v:U32 = Read.U32(r);
						buf.writeByte(op);
						buf.writeFloat(FPHelper.i32ToFloat(v));
						// LittleEndian.PutUint32(buf, v);
					}
				case f64Const:
					{
						buf.writeByte(op);
						// Todo: Make this accurate!
						#if cs
						var v:U64 = Read.U64(r);
						var i:I64 = untyped __cs__('(long){0}', v);
						var x:Float = untyped __cs__('System.BitConverter.Int64BitsToDouble({0})', i);
						buf.writeDouble(x);
						#elseif cpp
						var v:U64 = Read.U64(r);
						untyped __cpp__('int64_t vv = ({0} >> 11) | (0x3FFL << 53)', v);
						var x:Float = untyped __cpp__('*(double*)&vv');
						buf.writeDouble(x);
						#else
						var v = Read.U64(r);
						buf.writeDouble(v);
						#end
					}
				case getGlobal:
					{
						buf.writeByte(op);
						LittleEndian.PutUint32(buf, Leb128.readUint32(r));
					}
				case end:
					{
						buf.writeByte(op);
						break;
					}
				default:
					{
						throw new InvalidInitExprOpError(b.get(0));
					}
			}
		}
		if (buf.length == 0) {
			throw new ErrorEmptyInitExpr();
		}
		var ret = buf.getBytes();
		return ret;
	}

	static function floatToHex(f:Bytes) {}

	/**
	 * executes an initializer expression and returns a value
	 * which can either be int32, int64, float32 or float64.
	 * It throws an error if the expression is invalid, and nil when the expression
	 * yields no value.
	 * @param expr
	 * @return Dynamic
	 */
	public static function execInitExpr(module:Module, expr:Bytes):Dynamic {
		var stack:Array<Dynamic> = [];
		var lastVal:ValueType = -1;
		var r = new BytesInput(expr);

		if (r.length == 0) {
			throw new ErrorEmptyInitExpr();
		}
		while (true) {
			try {
				var b = r.readByte();


				// hack for invalid op at 0x00
				var bo = new BytesOutput();
				bo.writeByte(b);
				if (bo.getBytes().toHex() == "00") {
					continue;
				}


				var _break = false;
				switch b {
					case i32Const:
						{
							var i = Leb128.readInt32(r);
							#if !cs
							#if java
							stack.push(numerix.ULong.valueOf(i));
							#else
							stack.push(cast i);
							#end
							#else
							stack.push(untyped __cs__('System.Convert.ToUInt64({0})', i));
							#end
							lastVal = ValueTypeI32;
						}
					case i64Const:
						{
							var i = Leb128.readInt64(r);
							#if !cs
							#if java
							stack.push(numerix.ULong.valueOf(i));
							#else
							stack.push(cast i);
							#end
							#else
							stack.push(untyped __cs__('System.Convert.ToUInt64({0})', i));
							#end
							lastVal = ValueTypeI64;
						}
					case f32Const:
						{
							var i = Read.U32(r);
							#if !cs
							#if java
							stack.push(numerix.ULong.valueOf(i));
							#else
							stack.push(cast i);
							#end
							#else
							stack.push(untyped __cs__('System.Convert.ToUInt64({0})', i));
							#end
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
			} catch (e:Dynamic) {
				if (Std.is(e, Eof)) {
					break;
				} else {
					throw e;
				}
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
					return v;
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
