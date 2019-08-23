package wasp.sections;

import binary128.internal.Leb128;
import haxe.io.*;
import wasp.io.*;
import wasp.types.*;



class NameSection extends RawSection {
    public var types:Map<NameType, Bytes>;


    override function fromWasm(r:BytesInput) {
       types = new Map<NameType, Bytes>();
       while(true){
            var type = Leb128.readUint32(r);
            var data = Read.bytesUint(r);
            types.set(new NameType(type), data);
       }
    }

    override function toWasm(w:BytesOutput) {
        var keys:Array<NameType> = [];
        for(k=>_ in types){
            keys.push(k);
        }

        keys.sort((i, j)->{
            return -1;
        });

        for(k in keys){
            var data = types.get(k);
            Leb128.writeUint32(w, k);
            Encode.writeBytesUint(w, data);
        }
    }


    public function decode(type:NameType):NameSubSection {
        var sub:NameSubSection = null;
        switch type {
            case NameModule:{
                sub = new ModuleName();
            }
            case NameFunction:{
                sub = new FunctionNames();
            }
            case NameLocal:{
                sub = new LocalNames();
            }
            default: throw 'unsupported name subsection: $type';
        }
        
        if(types.exists(type)){
            var data = types[type];
            sub.fromWasm(new BytesInput(data));
        }
        return sub;
    }
}