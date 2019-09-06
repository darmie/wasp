package wasp.types;

import haxe.io.*;
import binary128.internal.Leb128;
import wasp.Global.*;
/**
 * describes a group of repeated elements that begin at a specified offset
 */
class ElementSegment implements Marshaller {
    /**
     * The index into the global table space, should always be 0 in the MVP.
     */
    public var index:Int;

	/**
	 * initializer expression for computing the offset for placing elements, should return an i32 value
	 */
	public var offset:Bytes; 
	public var elems:Array<Int>;

	public function new() {
		
	}


	public function fromWasm(r:BytesInput) {
		index = Leb128.readUint32(r);
		offset = readInitExpr(r);

		var numElems = Leb128.readUint32(r);
        
		for(i in 0...cast(numElems, Int)){
			var e = Leb128.readUint32(r);
			elems.push(e);
		}
	}

	public function toWasm(w:BytesOutput) {
		Leb128.writeUint32(w, index);
		w.write(offset);
		Leb128.writeUint32(w, elems.length);
		for(e in elems){
			Leb128.writeUint32(w, e);
		}
	}
}