package wasp.sections;

import haxe.io.*;
import binary128.internal.Leb128;
import wasp.types.*;
import hex.log.HexLog.*;

/**
 * describes the body for every function declared inside a module.
 */
class Code extends RawSection {
    public var bodies:Array<FunctionBody>;

    override function sectionID():SectionID {
        return SectionIDCode;
    }

    override function readPayload(r:BytesInput) {
        // super.readPayload(r);
        var count = Leb128.readUint32(r);
        this.bodies = new Array<FunctionBody>();
        info('$count function bodies');
        
        for(i in 0...cast(count, Int)){
            info('Reading function $i');
            var body:FunctionBody = new FunctionBody();
            body.fromWasm(r);
            this.bodies.push(body);
        } 
    }

    override function writePayload(w:BytesOutput) {
       Leb128.writeUint32(w, bodies.length);
       for(b in bodies){
           b.toWasm(w);
       }
    }
}