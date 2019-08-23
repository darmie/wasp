package wasp.sections;

import haxe.io.BytesOutput;
import haxe.io.BytesBuffer;
import haxe.io.BytesInput;
import haxe.Int64;
import haxe.io.Bytes;

class RawSection implements Section {
    public var start:Int64;
    public var end:Int64;

    public var id:SectionID;
    public var bytes:Bytes;

    public function new() {
        
    }

    public function sectionID():SectionID{
        return this.id;
    }

    public function getRawSection():RawSection {
        return this;
    }

    public function readPayload(r:BytesInput):Void {
        
    }

    public function writePayload(w:BytesOutput):Void {
        
    }

    public function toWasm(w:BytesOutput):Void {
        
    }

    public function fromWasm(r:BytesInput):Void {
        
    }

}