package wasp.types;

enum abstract NameType(UInt) from UInt to UInt {

    public inline function new(i) this = i;

    var NameModule;
    var NameFunction;
    var NameLocal;


    @:op(a<b) public function lt( b):Bool{
        return this < b;
    }

    @:op(a>b) public function gt( b):Bool{
        return this > b;
    }
}