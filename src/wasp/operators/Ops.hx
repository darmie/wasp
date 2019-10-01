package wasp.operators;

import wasp.types.BlockType;
import wasp.types.ValueType;
import wasp.operators.InstructionSet;

enum abstract Ops(Int) from Int to Int {
	// public inline function new(i:Int) this = i;
	var I32Eqz = 0x45;
	var I32Eq = 0x46;
	var I32Ne = 0x47;
	var I32LtS = 0x48;
	var I32LtU = 0x49;
	var I32GtS = 0x4a;
	var I32GtU = 0x4b;
	var I32LeS = 0x4c;
	var I32LeU = 0x4d;
	var I32GeS = 0x4e;
	var I32GeU = 0x4f;
	var I64Eqz = 0x50;
	var I64Eq = 0x51;
	var I64Ne = 0x52;
	var I64LtS = 0x53;
	var I64LtU = 0x54;
	var I64GtS = 0x55;
	var I64GtU = 0x56;
	var I64LeS = 0x57;
	var I64LeU = 0x58;
	var I64GeS = 0x59;
	var I64GeU = 0x5a;
	var F32Eq = 0x5b;
	var F32Ne = 0x5c;
	var F32Lt = 0x5d;
	var F32Gt = 0x5e;
	var F32Le = 0x5f;
	var F32Ge = 0x60;
	var F64Eq = 0x61;
	var F64Ne = 0x62;
	var F64Lt = 0x63;
	var F64Gt = 0x64;
	var F64Le = 0x65;
	var F64Ge = 0x66;
	var I32Const = 0x41;
	var I64Const = 0x42;
	var F32Const = 0x43;
	var F64Const = 0x44;
	var GetLocal = 0x20;
	var SetLocal = 0x21;
	var TeeLocal = 0x22;
	var GetGlobal = 0x23;
	var SetGlobal = 0x24;
	var Unreachable = 0x00;
	var Nop = 0x01;
	var Block = 0x02;
	var Loop = 0x03;
	var If = 0x04;
	var Else = 0x05;
	var End = 0x0b;
	var Br = 0x0c;
	var BrIf = 0x0d;
	var BrTable = 0x0e;
	var Return = 0x0f;
	var Call = 0x10;
	var CallIndirect = 0x11;
	var I32WrapI64 = 0xa7;
	var I32TruncSF32 = 0xa8;
	var I32TruncUF32 = 0xa9;
	var I32TruncSF64 = 0xaa;
	var I32TruncUF64 = 0xab;
	var I64ExtendSI32 = 0xac;
	var I64ExtendUI32 = 0xad;
	var I64TruncSF32 = 0xae;
	var I64TruncUF32 = 0xaf;
	var I64TruncSF64 = 0xb0;
	var I64TruncUF64 = 0xb1;
	var F32ConvertSI32 = 0xb2;
	var F32ConvertUI32 = 0xb3;
	var F32ConvertSI64 = 0xb4;
	var F32ConvertUI64 = 0xb5;
	var F32DemoteF64 = 0xb6;
	var F64ConvertSI32 = 0xb7;
	var F64ConvertUI32 = 0xb8;
	var F64ConvertSI64 = 0xb9;
	var F64ConvertUI64 = 0xba;
	var F64PromoteF32 = 0xbb;
	var I32Load = 0x28;
	var I64Load = 0x29;
	var F32Load = 0x2a;
	var F64Load = 0x2b;
	var I32Load8s = 0x2c;
	var I32Load8u = 0x2d;
	var I32Load16s = 0x2e;
	var I32Load16u = 0x2f;
	var I64Load8s = 0x30;
	var I64Load8u = 0x31;
	var I64Load16s = 0x32;
	var I64Load16u = 0x33;
	var I64Load32s = 0x34;
	var I64Load32u = 0x35;
	var I32Store = 0x36;
	var I64Store = 0x37;
	var F32Store = 0x38;
	var F64Store = 0x39;
	var I32Store8 = 0x3a;
	var I32Store16 = 0x3b;
	var I64Store8 = 0x3c;
	var I64Store16 = 0x3d;
	var I64Store32 = 0x3e;
	// TODO: rename operations accordingly
	var CurrentMemory = 0x3f;
	var GrowMemory = 0x40;
	var I32Clz = 0x67;
	var I32Ctz = 0x68;
	var I32Popcnt = 0x69;
	var I32Add = 0x6a;
	var I32Sub = 0x6b;
	var I32Mul = 0x6c;
	var I32DivS = 0x6d;
	var I32DivU = 0x6e;
	var I32RemS = 0x6f;
	var I32RemU = 0x70;
	var I32And = 0x71;
	var I32Or = 0x72;
	var I32Xor = 0x73;
	var I32Shl = 0x74;
	var I32ShrS = 0x75;
	var I32ShrU = 0x76;
	var I32Rotl = 0x77;
	var I32Rotr = 0x78;
	var I64Clz = 0x79;
	var I64Ctz = 0x7a;
	var I64Popcnt = 0x7b;
	var I64Add = 0x7c;
	var I64Sub = 0x7d;
	var I64Mul = 0x7e;
	var I64DivS = 0x7f;
	var I64DivU = 0x80;
	var I64RemS = 0x81;
	var I64RemU = 0x82;
	var I64And = 0x83;
	var I64Or = 0x84;
	var I64Xor = 0x85;
	var I64Shl = 0x86;
	var I64ShrS = 0x87;
	var I64ShrU = 0x88;
	var I64Rotl = 0x89;
	var I64Rotr = 0x8a;
	var F32Abs = 0x8b;
	var F32Neg = 0x8c;
	var F32Ceil = 0x8d;
	var F32Floor = 0x8e;
	var F32Trunc = 0x8f;
	var F32Nearest = 0x90;
	var F32Sqrt = 0x91;
	var F32Add = 0x92;
	var F32Sub = 0x93;
	var F32Mul = 0x94;
	var F32Div = 0x95;
	var F32Min = 0x96;
	var F32Max = 0x97;
	var F32Copysign = 0x98;
	var F64Abs = 0x99;
	var F64Neg = 0x9a;
	var F64Ceil = 0x9b;
	var F64Floor = 0x9c;
	var F64Trunc = 0x9d;
	var F64Nearest = 0x9e;
	var F64Sqrt = 0x9f;
	var F64Add = 0xa0;
	var F64Sub = 0xa1;
	var F64Mul = 0xa2;
	var F64Div = 0xa3;
	var F64Min = 0xa4;
	var F64Max = 0xa5;
	var F64Copysign = 0xa6;
	var Drop = 0x1a;
	var Select = 0x1b;
	var I32ReinterpretF32 = 0xbc;
	var I64ReinterpretF64 = 0xbd;
	var F32ReinterpretI32 = 0xbe;
	var F64ReinterpretI64 = 0xbf;


	private inline function conversion(code:Int, name:String){
		var r = ~/(.+)\.(?:[a-z]|_)+\/(.+)/g;
		if (r.match(name)) {
			var returns = valType(r.matched(1));
			var param = valType(r.matched(2));
			return InstructionSet.Op(code, name, [param], returns);
		}
		throw 'invalid conversion type: $name';
	}

	private inline function valType(s:String):ValueType {
		return switch s {
			case "i32":
				ValueTypeI32;
			case "i64":
				ValueTypeI64;
			case "f32":
				ValueTypeF32;
			case "f64":
				ValueTypeF64;
			default:
				throw 'Invalid value type string: $s';
		}
	}


	public inline function returns():ValueType {
		var isa:InstructionSet = toIntr();
		return  switch (isa){
			case Op(_, _, _, ret): ret;
			default: throw "Op has no return value, check if it's polymorphic";
		}
	}

	public inline function args():Array<ValueType>{
		var isa:InstructionSet = toIntr();
		return  switch (isa){
			case Op(_, _, args, _): args;
			case _: [];
		}
	}


	public inline function isPolymorphic():Bool {
		var isa:InstructionSet = toIntr();
		return  switch (isa){
			case OpPolymorphic(_, _): true;
			case _: false;
		}
	}

	public inline function toString():String {
		var isa:InstructionSet = toIntr();
		return  switch (isa){
			case Op(_, name, _, _): name;
			case OpPolymorphic(_, name): name;
		}
	}

	@:from public static inline function fromInstr(isa:InstructionSet):Ops {
		return  switch (isa){
			case Op(code, _, _, _): code;
			case OpPolymorphic(code, _): code;
		}
	}

	@:to public function toIntr():InstructionSet {
		return switch this {
			case I32Eqz: InstructionSet.Op(0x45, "i32.eqz", [ValueTypeI32], ValueTypeI32);
			case I32Eq: InstructionSet.Op(0x46, "i32.eq", [ValueTypeI32, ValueTypeI32], ValueTypeI32);
			case I32Ne: InstructionSet.Op(0x47, "i32.ne", [ValueTypeI32, ValueTypeI32], ValueTypeI32);
			case I32LtS: InstructionSet.Op(0x48, "i32.lt_s", [ValueTypeI32, ValueTypeI32], ValueTypeI32);
			case I32LtU: InstructionSet.Op(0x49, "i32.lt_u", [ValueTypeI32, ValueTypeI32], ValueTypeI32);
			case I32GtS: InstructionSet.Op(0x4a, "i32.gt_s", [ValueTypeI32, ValueTypeI32], ValueTypeI32);
			case I32GtU: InstructionSet.Op(0x4b, "i32.gt_u", [ValueTypeI32, ValueTypeI32], ValueTypeI32);
			case I32LeS: InstructionSet.Op(0x4c, "i32.le_s", [ValueTypeI32, ValueTypeI32], ValueTypeI32);
			case I32LeU: InstructionSet.Op(0x4d, "i32.le_u", [ValueTypeI32, ValueTypeI32], ValueTypeI32);
			case I32GeS: InstructionSet.Op(0x4e, "i32.ge_s", [ValueTypeI32, ValueTypeI32], ValueTypeI32);
			case I32GeU: InstructionSet.Op(0x4f, "i32.ge_u", [ValueTypeI32, ValueTypeI32], ValueTypeI32);
			case I64Eqz: InstructionSet.Op(0x50, "i64.eqz", [ValueTypeI64], ValueTypeI32);
			case I64Eq: InstructionSet.Op(0x51, "i64.eq", [ValueTypeI64, ValueTypeI64], ValueTypeI32);
			case I64Ne: InstructionSet.Op(0x52, "i64.ne", [ValueTypeI64, ValueTypeI64], ValueTypeI32);
			case I64LtS: InstructionSet.Op(0x53, "i64.lt_s", [ValueTypeI64, ValueTypeI64], ValueTypeI32);
			case I64LtU: InstructionSet.Op(0x54, "i64.lt_u", [ValueTypeI64, ValueTypeI64], ValueTypeI32);
			case I64GtS: InstructionSet.Op(0x55, "i64.gt_s", [ValueTypeI64, ValueTypeI64], ValueTypeI32);
			case I64GtU: InstructionSet.Op(0x56, "i64.gt_u", [ValueTypeI64, ValueTypeI64], ValueTypeI32);
			case I64LeS: InstructionSet.Op(0x57, "i64.le_s", [ValueTypeI64, ValueTypeI64], ValueTypeI32);
			case I64LeU: InstructionSet.Op(0x58, "i64.le_u", [ValueTypeI64, ValueTypeI64], ValueTypeI32);
			case I64GeS: InstructionSet.Op(0x59, "i64.ge_s", [ValueTypeI64, ValueTypeI64], ValueTypeI32);
			case I64GeU: InstructionSet.Op(0x5a, "i64.ge_u", [ValueTypeI64, ValueTypeI64], ValueTypeI32);
			case F32Eq: InstructionSet.Op(0x5b, "f32.eq", [ValueTypeF32, ValueTypeF32], ValueTypeI32);
			case F32Ne: InstructionSet.Op(0x5c, "f32.ne", [ValueTypeF32, ValueTypeF32], ValueTypeI32);
			case F32Lt: InstructionSet.Op(0x5d, "f32.lt", [ValueTypeF32, ValueTypeF32], ValueTypeI32);
			case F32Gt: InstructionSet.Op(0x5e, "f32.gt", [ValueTypeF32, ValueTypeF32], ValueTypeI32);
			case F32Le: InstructionSet.Op(0x5f, "f32.le", [ValueTypeF32, ValueTypeF32], ValueTypeI32);
			case F32Ge: InstructionSet.Op(0x60, "f32.ge", [ValueTypeF32, ValueTypeF32], ValueTypeI32);
			case F64Eq: InstructionSet.Op(0x61, "f64.eq", [ValueTypeF64, ValueTypeF64], ValueTypeI32);
			case F64Ne: InstructionSet.Op(0x62, "f64.ne", [ValueTypeF64, ValueTypeF64], ValueTypeI32);
			case F64Lt: InstructionSet.Op(0x63, "f64.lt", [ValueTypeF64, ValueTypeF64], ValueTypeI32);
			case F64Gt: InstructionSet.Op(0x64, "f64.gt", [ValueTypeF64, ValueTypeF64], ValueTypeI32);
			case F64Le: InstructionSet.Op(0x65, "f64.le", [ValueTypeF64, ValueTypeF64], ValueTypeI32);
			case F64Ge: InstructionSet.Op(0x66, "f64.ge", [ValueTypeF64, ValueTypeF64], ValueTypeI32);

			case I32Const: InstructionSet.Op(0x41, "i32.const", null, ValueTypeI32);
			case I64Const: InstructionSet.Op(0x42, "i64.const", null, ValueTypeI64);
			case F32Const: InstructionSet.Op(0x43, "f32.const", null, ValueTypeF32);
			case F64Const: InstructionSet.Op(0x44, "f64.const", null, ValueTypeF64);

			case GetLocal: InstructionSet.OpPolymorphic(0x20, "get_local");
			case SetLocal: InstructionSet.OpPolymorphic(0x21, "set_local");
			case TeeLocal: InstructionSet.OpPolymorphic(0x22, "tee_local");
			case GetGlobal: InstructionSet.OpPolymorphic(0x23, "get_global");
			case SetGlobal: InstructionSet.OpPolymorphic(0x24, "set_global");

			case Unreachable: InstructionSet.Op(0x00, "unreachable", null, cast(BlockTypeEmpty, ValueType));
			case Nop: InstructionSet.Op(0x01, "nop", null, cast(BlockTypeEmpty, ValueType));
			case Block: InstructionSet.Op(0x02, "block", null, cast(BlockTypeEmpty, ValueType));
			case Loop: InstructionSet.Op(0x03, "loop", null, cast(BlockTypeEmpty, ValueType));
			case If: InstructionSet.Op(0x04, "if", [ValueTypeI32], cast(BlockTypeEmpty, ValueType));
			case Else: InstructionSet.Op(0x05, "else", null, cast(BlockTypeEmpty, ValueType));
			case End: InstructionSet.Op(0x0b, "end", null, cast(BlockTypeEmpty, ValueType));
			case Br: InstructionSet.OpPolymorphic(0x0c, "br");
			case BrIf: InstructionSet.Op(0x0d, "br_if", [ValueTypeI32], cast(BlockTypeEmpty, ValueType));
			case BrTable: InstructionSet.OpPolymorphic(0x0e, "br_table");
			case Return: InstructionSet.OpPolymorphic(0x0f, "return");

			case Call: InstructionSet.OpPolymorphic(0x10, "call");
			case CallIndirect: InstructionSet.OpPolymorphic(0x11, "call_indirect");

			case I32WrapI64: conversion(0xa7, "i32.wrap/i64");
			case I32TruncSF32: conversion(0xa8, "i32.trunc_s/f32");
			case I32TruncUF32: conversion(0xa9, "i32.trunc_u/f32");
			case I32TruncSF64: conversion(0xaa, "i32.trunc_s/f64");
			case I32TruncUF64: conversion(0xab, "i32.trunc_u/f64");
			case I64ExtendSI32: conversion(0xac, "i64.extend_s/i32");
			case I64ExtendUI32: conversion(0xad, "i64.extend_u/i32");
			case I64TruncSF32: conversion(0xae, "i64.trunc_s/f32");
			case I64TruncUF32: conversion(0xaf, "i64.trunc_u/f32");
			case I64TruncSF64: conversion(0xb0, "i64.trunc_s/f64");
			case I64TruncUF64: conversion(0xb1, "i64.trunc_u/f64");
			case F32ConvertSI32: conversion(0xb2, "f32.convert_s/i32");
			case F32ConvertUI32: conversion(0xb3, "f32.convert_u/i32");
			case F32ConvertSI64: conversion(0xb4, "f32.convert_s/i64");
			case F32ConvertUI64: conversion(0xb5, "f32.convert_u/i64");
			case F32DemoteF64: conversion(0xb6, "f32.demote/f64");
			case F64ConvertSI32: conversion(0xb7, "f64.convert_s/i32");
			case F64ConvertUI32: conversion(0xb8, "f64.convert_u/i32");
			case F64ConvertSI64: conversion(0xb9, "f64.convert_s/i64");
			case F64ConvertUI64: conversion(0xba, "f64.convert_u/i64");
			case F64PromoteF32: conversion(0xbb, "f64.promote/f32");
			case I32Load: InstructionSet.Op(0x28, "i32.load", [ValueTypeI32], ValueTypeI32);
			case I64Load: InstructionSet.Op(0x29, "i64.load", [ValueTypeI32], ValueTypeI64);
			case F32Load: InstructionSet.Op(0x2a, "f32.load", [ValueTypeI32], ValueTypeF32);
			case F64Load: InstructionSet.Op(0x2b, "f64.load", [ValueTypeI32], ValueTypeF64);
			case I32Load8s: InstructionSet.Op(0x2c, "i32.load8_s", [ValueTypeI32], ValueTypeI32);
			case I32Load8u: InstructionSet.Op(0x2d, "i32.load8_u", [ValueTypeI32], ValueTypeI32);
			case I32Load16s: InstructionSet.Op(0x2e, "i32.load16_s", [ValueTypeI32], ValueTypeI32);
			case I32Load16u: InstructionSet.Op(0x2f, "i32.load16_u", [ValueTypeI32], ValueTypeI32);
			case I64Load8s: InstructionSet.Op(0x30, "i64.load8_s", [ValueTypeI32], ValueTypeI64);
			case I64Load8u: InstructionSet.Op(0x31, "i64.load8_u", [ValueTypeI32], ValueTypeI64);
			case I64Load16s: InstructionSet.Op(0x32, "i64.load16_s", [ValueTypeI32], ValueTypeI64);
			case I64Load16u: InstructionSet.Op(0x33, "i64.load16_u", [ValueTypeI32], ValueTypeI64);
			case I64Load32s: InstructionSet.Op(0x34, "i64.load32_s", [ValueTypeI32], ValueTypeI64);
			case I64Load32u: InstructionSet.Op(0x35, "i64.load32_u", [ValueTypeI32], ValueTypeI64);
			case I32Store: InstructionSet.Op(0x36, "i32.store", [ValueTypeI32, ValueTypeI32], cast(BlockTypeEmpty, ValueType));
			case I64Store: InstructionSet.Op(0x37, "i64.store", [ValueTypeI64, ValueTypeI32], cast(BlockTypeEmpty, ValueType));
			case F32Store: InstructionSet.Op(0x38, "f32.store", [ValueTypeF32, ValueTypeI32], cast(BlockTypeEmpty, ValueType));
			case F64Store: InstructionSet.Op(0x39, "f64.store", [ValueTypeF64, ValueTypeI32], cast(BlockTypeEmpty, ValueType));
			case I32Store8: InstructionSet.Op(0x3a, "i32.store8", [ValueTypeI32, ValueTypeI32], cast(BlockTypeEmpty, ValueType));
			case I32Store16: InstructionSet.Op(0x3b, "i32.store16", [ValueTypeI32, ValueTypeI32], cast(BlockTypeEmpty, ValueType));
			case I64Store8: InstructionSet.Op(0x3c, "i64.store8", [ValueTypeI64, ValueTypeI32], cast(BlockTypeEmpty, ValueType));
			case I64Store16: InstructionSet.Op(0x3d, "i64.store16", [ValueTypeI64, ValueTypeI32], cast(BlockTypeEmpty, ValueType));
			case I64Store32: InstructionSet.Op(0x3e, "i64.store32", [ValueTypeI64, ValueTypeI32], cast(BlockTypeEmpty, ValueType));
			// TODO: rename operations accordingly
			case CurrentMemory: InstructionSet.Op(0x3f, "memory.size", null, ValueTypeI32);
			case GrowMemory: InstructionSet.Op(0x40, "memory.grow", [ValueTypeI32], ValueTypeI32);

			case I32Clz: InstructionSet.Op(0x67, "i32.clz", [ValueTypeI32], ValueTypeI32);
			case I32Ctz: InstructionSet.Op(0x68, "i32.ctz", [ValueTypeI32], ValueTypeI32);
			case I32Popcnt: InstructionSet.Op(0x69, "i32.popcnt", [ValueTypeI32], ValueTypeI32);
			case I32Add: InstructionSet.Op(0x6a, "i32.add", [ValueTypeI32, ValueTypeI32], ValueTypeI32);
			case I32Sub: InstructionSet.Op(0x6b, "i32.sub", [ValueTypeI32, ValueTypeI32], ValueTypeI32);
			case I32Mul: InstructionSet.Op(0x6c, "i32.mul", [ValueTypeI32, ValueTypeI32], ValueTypeI32);
			case I32DivS: InstructionSet.Op(0x6d, "i32.div_s", [ValueTypeI32, ValueTypeI32], ValueTypeI32);
			case I32DivU: InstructionSet.Op(0x6e, "i32.div_u", [ValueTypeI32, ValueTypeI32], ValueTypeI32);
			case I32RemS: InstructionSet.Op(0x6f, "i32.rem_s", [ValueTypeI32, ValueTypeI32], ValueTypeI32);
			case I32RemU: InstructionSet.Op(0x70, "i32.rem_u", [ValueTypeI32, ValueTypeI32], ValueTypeI32);
			case I32And: InstructionSet.Op(0x71, "i32.and", [ValueTypeI32, ValueTypeI32], ValueTypeI32);
			case I32Or: InstructionSet.Op(0x72, "i32.or", [ValueTypeI32, ValueTypeI32], ValueTypeI32);
			case I32Xor: InstructionSet.Op(0x73, "i32.xor", [ValueTypeI32, ValueTypeI32], ValueTypeI32);
			case I32Shl: InstructionSet.Op(0x74, "i32.shl", [ValueTypeI32, ValueTypeI32], ValueTypeI32);
			case I32ShrS: InstructionSet.Op(0x75, "i32.shr_s", [ValueTypeI32, ValueTypeI32], ValueTypeI32);
			case I32ShrU: InstructionSet.Op(0x76, "i32.shr_u", [ValueTypeI32, ValueTypeI32], ValueTypeI32);
			case I32Rotl: InstructionSet.Op(0x77, "i32.rotl", [ValueTypeI32, ValueTypeI32], ValueTypeI32);
			case I32Rotr: InstructionSet.Op(0x78, "i32.rotr", [ValueTypeI32, ValueTypeI32], ValueTypeI32);
			case I64Clz: InstructionSet.Op(0x79, "i64.clz", [ValueTypeI64], ValueTypeI64);
			case I64Ctz: InstructionSet.Op(0x7a, "i64.ctz", [ValueTypeI64], ValueTypeI64);
			case I64Popcnt: InstructionSet.Op(0x7b, "i64.popcnt", [ValueTypeI64], ValueTypeI64);
			case I64Add: InstructionSet.Op(0x7c, "i64.add", [ValueTypeI64, ValueTypeI64], ValueTypeI64);
			case I64Sub: InstructionSet.Op(0x7d, "i64.sub", [ValueTypeI64, ValueTypeI64], ValueTypeI64);
			case I64Mul: InstructionSet.Op(0x7e, "i64.mul", [ValueTypeI64, ValueTypeI64], ValueTypeI64);
			case I64DivS: InstructionSet.Op(0x7f, "i64.div_s", [ValueTypeI64, ValueTypeI64], ValueTypeI64);
			case I64DivU: InstructionSet.Op(0x80, "i64.div_u", [ValueTypeI64, ValueTypeI64], ValueTypeI64);
			case I64RemS: InstructionSet.Op(0x81, "i64.rem_s", [ValueTypeI64, ValueTypeI64], ValueTypeI64);
			case I64RemU: InstructionSet.Op(0x82, "i64.rem_u", [ValueTypeI64, ValueTypeI64], ValueTypeI64);
			case I64And: InstructionSet.Op(0x83, "i64.and", [ValueTypeI64, ValueTypeI64], ValueTypeI64);
			case I64Or: InstructionSet.Op(0x84, "i64.or", [ValueTypeI64, ValueTypeI64], ValueTypeI64);
			case I64Xor: InstructionSet.Op(0x85, "i64.xor", [ValueTypeI64, ValueTypeI64], ValueTypeI64);
			case I64Shl: InstructionSet.Op(0x86, "i64.shl", [ValueTypeI64, ValueTypeI64], ValueTypeI64);
			case I64ShrS: InstructionSet.Op(0x87, "i64.shr_s", [ValueTypeI64, ValueTypeI64], ValueTypeI64);
			case I64ShrU: InstructionSet.Op(0x88, "i64.shr_u", [ValueTypeI64, ValueTypeI64], ValueTypeI64);
			case I64Rotl: InstructionSet.Op(0x89, "i64.rotl", [ValueTypeI64, ValueTypeI64], ValueTypeI64);
			case I64Rotr: InstructionSet.Op(0x8a, "i64.rotr", [ValueTypeI64, ValueTypeI64], ValueTypeI64);
			case F32Abs: InstructionSet.Op(0x8b, "f32.abs", [ValueTypeF32], ValueTypeF32);
			case F32Neg: InstructionSet.Op(0x8c, "f32.neg", [ValueTypeF32], ValueTypeF32);
			case F32Ceil: InstructionSet.Op(0x8d, "f32.ceil", [ValueTypeF32], ValueTypeF32);
			case F32Floor: InstructionSet.Op(0x8e, "f32.floor", [ValueTypeF32], ValueTypeF32);
			case F32Trunc: InstructionSet.Op(0x8f, "f32.trunc", [ValueTypeF32], ValueTypeF32);
			case F32Nearest: InstructionSet.Op(0x90, "f32.nearest", [ValueTypeF32], ValueTypeF32);
			case F32Sqrt: InstructionSet.Op(0x91, "f32.sqrt", [ValueTypeF32], ValueTypeF32);
			case F32Add: InstructionSet.Op(0x92, "f32.add", [ValueTypeF32, ValueTypeF32], ValueTypeF32);
			case F32Sub: InstructionSet.Op(0x93, "f32.sub", [ValueTypeF32, ValueTypeF32], ValueTypeF32);
			case F32Mul: InstructionSet.Op(0x94, "f32.mul", [ValueTypeF32, ValueTypeF32], ValueTypeF32);
			case F32Div: InstructionSet.Op(0x95, "f32.div", [ValueTypeF32, ValueTypeF32], ValueTypeF32);
			case F32Min: InstructionSet.Op(0x96, "f32.min", [ValueTypeF32, ValueTypeF32], ValueTypeF32);
			case F32Max: InstructionSet.Op(0x97, "f32.max", [ValueTypeF32, ValueTypeF32], ValueTypeF32);
			case F32Copysign: InstructionSet.Op(0x98, "f32.copysign", [ValueTypeF32, ValueTypeF32], ValueTypeF32);
			case F64Abs: InstructionSet.Op(0x99, "f64.abs", [ValueTypeF64], ValueTypeF64);
			case F64Neg: InstructionSet.Op(0x9a, "f64.neg", [ValueTypeF64], ValueTypeF64);
			case F64Ceil: InstructionSet.Op(0x9b, "f64.ceil", [ValueTypeF64], ValueTypeF64);
			case F64Floor: InstructionSet.Op(0x9c, "f64.floor", [ValueTypeF64], ValueTypeF64);
			case F64Trunc: InstructionSet.Op(0x9d, "f64.trunc", [ValueTypeF64], ValueTypeF64);
			case F64Nearest: InstructionSet.Op(0x9e, "f64.nearest", [ValueTypeF64], ValueTypeF64);
			case F64Sqrt: InstructionSet.Op(0x9f, "f64.sqrt", [ValueTypeF64], ValueTypeF64);
			case F64Add: InstructionSet.Op(0xa0, "f64.add", [ValueTypeF64, ValueTypeF64], ValueTypeF64);
			case F64Sub: InstructionSet.Op(0xa1, "f64.sub", [ValueTypeF64, ValueTypeF64], ValueTypeF64);
			case F64Mul: InstructionSet.Op(0xa2, "f64.mul", [ValueTypeF64, ValueTypeF64], ValueTypeF64);
			case F64Div: InstructionSet.Op(0xa3, "f64.div", [ValueTypeF64, ValueTypeF64], ValueTypeF64);
			case F64Min: InstructionSet.Op(0xa4, "f64.min", [ValueTypeF64, ValueTypeF64], ValueTypeF64);
			case F64Max: InstructionSet.Op(0xa5, "f64.max", [ValueTypeF64, ValueTypeF64], ValueTypeF64);
			case F64Copysign: InstructionSet.Op(0xa6, "f64.copysign", [ValueTypeF64, ValueTypeF64], ValueTypeF64);
			case Drop: InstructionSet.OpPolymorphic(0x1a, "drop");
			case Select: InstructionSet.OpPolymorphic(0x1b, "select");

			case I32ReinterpretF32: InstructionSet.Op(0xbc, "i32.reinterpret/f32", [ValueTypeF32], ValueTypeI32);
			case I64ReinterpretF64: InstructionSet.Op(0xbd, "i64.reinterpret/f64", [ValueTypeF64], ValueTypeI64);
			case F32ReinterpretI32: InstructionSet.Op(0xbe, "f32.reinterpret/i32", [ValueTypeI32], ValueTypeF32);
			case F64ReinterpretI64: InstructionSet.Op(0xbf, "f64.reinterpret/i64", [ValueTypeI64], ValueTypeF64);
			default: throw 'invalid op $this';
		}
	}
}
