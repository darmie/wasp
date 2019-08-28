package wasp.internal;

abstract Stack(Array<Int>) {
    public inline function new() {
        this = [];
    }

    public function push(b:Int) {
        this.push(b);
    }

    public inline function pop():Int {
        var v = top();
        this.pop();
        return v;
    }

    public function top() {
        return this[this.length - 1];
    }

    public function setTop(v) {
        this[this.length - 1] = v;
    }

    @:arrayAccess public function get(i:Int):Int {
        return this[i];
    }

    @:arrayAccess public function set(i:Int, v:Int){
        return this[i] = v;
    }

    public function length():Int {
        return this.length;
    }


}