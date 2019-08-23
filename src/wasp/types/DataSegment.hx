package wasp.types;

import haxe.io.*;
import wasp.io.*;
import binary128.internal.Leb128;

import wasp.Global.*;


/**
 * Describes a group of repeated elements that begin at a specified offset in the linear memory
 */
class DataSegment {
     /**
     * The index into the global linear memory space, should always be 0 in the MVP.
     */
    public var index:Int;

	/**
	 * initializer expression for computing the offset for placing elements, should return an i32 value
	 */
	public var offset:Bytes; 
	public var data:Bytes; 

	public function new() {
		
	}  

	public function toWasm(w:BytesOutput):Void {
       Leb128.writeUint32(w, index);
	   w.write(offset);
	   Encode.writeBytesUint(w, data);
    }

    public function fromWasm(r:BytesInput):Void {
        index = Leb128.readUint32(r);
		offset = readInitExpr(r);
		data = Read.bytesUint(r);
    }
}