package wasp;

import wasp.types.*;

class Function {
    public var sig:FunctionSig;
    public var body:FunctionBody;

    public var host:Dynamic;

    public var name:String;

    public function new(_sig:FunctionSig, _body:FunctionBody, _name:String, _host:Dynamic = null) {
        sig = _sig;
        body = _body;
        name = _name;
        host = _host;
    }

    public function isHost():Bool {
        return Type.typeof(host) != TFunction;
    }
}