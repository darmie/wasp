package wasp.exceptions;

import wasp.sections.SectionID;

abstract MissingSectionError(SectionID) from SectionID to SectionID {
    public inline function new(s:SectionID) {
        this = s;
    }

    public inline function toString():String {
        return 'wasm: missing section $this';
    }
}