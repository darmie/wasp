package wasp.sections;

import haxe.io.*;
import wasp.types.*;

interface Section extends  Marshaller {
    /**
     * returns a section ID for WASM encoding. Should be unique across types.
     * @return SectionID
     */
    function sectionID():SectionID;
    /**
     * Returns an embedded RawSection pointer to populate generic fields.
     * @return RawSection
     */
    function getRawSection():RawSection;
    /**
     * reads a section payload, assuming the size was already read, and reader is limited to it.
     * @param r 
     */
    function readPayload(r:BytesInput):Void;
    /**
     * writes a section payload without the size.
     * Caller should calculate written size and add it before the payload.
     * @param w 
     */
    function writePayload(w:BytesOutput):Void;
}