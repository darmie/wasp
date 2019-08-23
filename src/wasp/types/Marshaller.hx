package wasp.types;

import haxe.io.*;

interface Marshaller {
    function fromWasm(r:BytesInput):Void;

    function toWasm(w:BytesOutput):Void;
}