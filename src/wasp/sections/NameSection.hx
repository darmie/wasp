package wasp.sections;

import binary128.internal.Leb128;
import haxe.io.*;
import wasp.io.*;
import wasp.types.*;

class NameSection extends RawSection {
	#if !cs
	public var types:Map<NameType, Bytes>;
	#else
	public var types:cs.system.collections.generic.Dictionary_2<NameType, Bytes>;
	#end

	override function fromWasm(r:BytesInput) {
		#if !cs
		types = new Map<NameType, Bytes>();
		#else
		types = new cs.system.collections.generic.Dictionary_2<NameType, Bytes>();
		#end
		while (true) {
			try {
				var type = Leb128.readUint32(r);
				var data = Read.bytesUint(r);
				var ntype = new NameType(type);
				#if !cs
				types.set(ntype, data);
				#else
				types.Add(ntype, data);
				#end
			}catch(e:Dynamic){
                if(Std.is(e, Eof)){
                    break;
                }else {
                    throw e;
                }
            }
		}
	}

	override function toWasm(w:BytesOutput) {
		var keys:Array<NameType> = [];

		#if !cs
		for (k => _ in types) {
			keys.push(k);
		}
		#else
		var count = types.Count;
		untyped __cs__('
        foreach(var item in {0}){
            {1}.push(item.Key);
        }
        var x = 0', types, keys, count);
		#end

		keys.sort((i, j) -> {
			return -1;
		});

		for (k in keys) {
			#if !cs
			var data = types.get(k);
			#else
			var data:Bytes = Bytes.alloc(0);
			types.TryGetValue(k, data);
			#end
			Leb128.writeUint32(w, k);
			Encode.writeBytesUint(w, data);
		}
	}

	public function decode(type:NameType):NameSubSection {
		var sub:NameSubSection = null;
		switch type {
			case NameModule:
				{
					sub = new ModuleName();
				}
			case NameFunction:
				{
					sub = new FunctionNames();
				}
			case NameLocal:
				{
					sub = new LocalNames();
				}
			default:
				throw 'unsupported name subsection: $type';
		}
		var exists = #if !cs types.exists(type); #else types.ContainsKey(type); #end
		if (exists) {
			// var data = types[type];
			#if !cs
			var data = types.get(type);
			#else
			var data:Bytes = Bytes.alloc(0);
			types.TryGetValue(type, data);
			#end
			sub.fromWasm(new BytesInput(data));
		}
		return sub;
	}
}
