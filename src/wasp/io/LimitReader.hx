package wasp.io;


import haxe.io.*;


class LimitReader extends  BytesInput {

    /**
     * max bytes remaining
     */
    var N:Int;
    public function new(r:BytesInput, n:Int) {
        super(r.readAll());
        N = n;
    }

    override public function readBytes(p:Bytes, pos:Int, len:Int):Int {
        if(N <= 0){
            throw Eof;
        }

        if(p.length > N){
            p = p.sub(0, N);
        }

        var n = super.readBytes(p, 0, p.length);
        N -= n;
        return n;
    }
}