package wasp.sections;

import haxe.io.BytesOutput;
import haxe.io.BytesInput;
// import haxe.ds.Map;
import binary128.internal.Leb128;
import wasp.types.ExportEntry;

/**
 * declares the export section of a module
 */
class Exports extends RawSection {
    public var entries:Map<String, ExportEntry>;
    public var names:Array<String> = [];

    public function new(){
        super();
    }

    override function sectionID():SectionID {
        return SectionIDExport;
    }

    override function readPayload(r:BytesInput) {
        var count = Leb128.readUint32(r);
        entries = new Map<String, ExportEntry>();

        for(i in 0...cast(count, Int)){
            var entry = new ExportEntry();
            entry.fromWasm(r);
            
            if(entries.exists(entry.fieldStr)){
                throw 'Duplicate export entry: ${entry.fieldStr}';
            }
            entries.set(entry.fieldStr, entry);
            names.push(entry.fieldStr);
        }
    }

    override function writePayload(w:BytesOutput) {
        Leb128.writeUint32(w, Lambda.count(entries));
        var _entries:Array<ExportEntry> = [];
        for(e in entries){
            _entries.push(e);
        }
        
        _entries.sort((i, j)->{
            if(i.index == j.index){
                if(i.fieldStr.toUpperCase() < j.fieldStr.toUpperCase()) {
                    return -1;
                }
            }
            return -1;
        });

        for(e in _entries){
            e.toWasm(w);
        }
    }
}