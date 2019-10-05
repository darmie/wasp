![wasp logo](wasp.png)  ![](https://travis-ci.org/darmie/wasp.svg?branch=master)

WebAssembly Utility for Haxe

 * Dissasemble `.wasm` to `.wast` and Haxe specific data representations.
 * Validate `.wasm` [WIP]


__WASP__ is based on portions of [Wagon](https://github.com/go-interpreter/wagon), a WebAssembly interpreter in [Go](https://golang.org), and ported to the [Haxe](https://haxe.org) programming language.

### Dependencies

 * [Haxe](https://haxe.org/)
 * [Binary128](https://github.com/darmie/binary128)
 * [Numerix](https://github.com/darmie/binary128)

Use the [Lix](https://github.com/lix-pm/lix.client) dependency manager 

Download dependencies 
```
lix download
```

### Compile

```
haxe build.hxml
```

### Usage

```hx

import wasp.Module;
import wasp.disasm.Disassembly;
import haxe.io.BytesInput;
import sys.FileSystem;
import sys.io.File;
import wasp.wast.Writer;

...

try {
    // get wasm binary
    var source = FileSystem.fullPath("globals.wasm");
    if (FileSystem.exists(source)) {
        var raw = File.getBytes(source); // get raw bytes
        var reader = new BytesInput(raw);

        var module = Module.read(reader, null); // read wasm module

        var output = new StringBuf();


        Writer.writeTo(output, module); // write wasm bytes to text dump (wat) 

        Sys.println(output.toString()); // print dump
    }
} catch(e:Any){
    throw e;
}
```

## Instruction Set Architecture
WASP provides an ISA that can be useful in an interpreter or virtual machine. 
The ISA is defined as such:

```hx
/**
 * ISA describes an instruction, consisting of an operator, with its
 * appropriate immediate value(s).
 */
typedef ISA = {
	?op:InstructionSet,

	/**
	 * Immediates are arguments to an operator in the bytecode stream itself.
	 * Valid value types are:
	 * - (u)(int/float)(32/64)
	 * - BlockType
	 */
	?immediates:Array<Dynamic>,
	// non-nil if the instruction creates or unwinds a stack.
	?newStack:StackInfo,
	// non-nil if the instruction starts or ends a new block.
	?block:BlockInfo,
	// whether the operator can be reached during execution
	?unreachable:Bool,
	// IsReturn is true if executing this instruction will result in the
	// function returning. This is true for branches (br, br_if) to
	// the depth <max_relative_depth> + 1, or the return operator itself.
	// If true, NewStack for this instruction is nil.
	?isReturn:Bool,
	// If the operator is br_table (ops.BrTable), this is a list of StackInfo
	// fields for each of the blocks/branches referenced by the operator.
	?branches:Array<StackInfo>
}

/**
 * StackInfo stores details about a new stack created or unwound by an instruction.
 */
typedef StackInfo = {
	// The difference between the stack depths at the end of the block
	?stackTopDiff:Int,
	// Whether the value on the top of the stack should be preserved while unwinding
	?preserveTop:Bool,
	// Whether the unwind is equivalent to a return
	?isReturn:Bool
}

/**
 * BlockInfo stores details about a block created or ended by an instruction.
 */
typedef BlockInfo = {
	?start:Bool, // If true, this instruction starts a block. Else this instruction ends it.
	?signature:BlockType, // 0x40

	// The block signature
	// Indices to the accompanying control operator.
	// For 'if', this is the index to the 'else' operator.
	?ifElseIndex:Int,   // For 'else', this is the index to the 'if' operator.
	?elseIfIndex:Int,   // The index to the `end' operator for if/else/loop/block.
	?endIndex:Int,      // For end, it is the index to the operator that starts the block.
	?blockStartIndex:Int
}
```

To decompile a wasm module into executable instruction sets, use the `Disassembler`.

```hx
var module = Module.read(reader, null); // read wasm module
var o = new StringBuf();
// compile the function index space
for(func in module.functionIndexSpace){
    var hasParams = func.sig.paramTypes.length != 0;
    var hasReturn = func.sig.returnTypes.length != 0;

    var code:Array<ISA> = new Disassembly(func, module).code;  // disassemble the function
    // Todo: execute !
    

    // dump text
    o.add("("); // open
    o.add("func ");
    if (hasParams) {
        var params = [for (_p in func.sig.paramTypes) _p.toString()].join(" ");
        o.add("("); // open
        o.add('param ${params}');
        o.add(")"); // close
    }
    if (hasReturn) {
        var ret = [for (_p in func.sig.returnTypes) _p.toString()].join(" ");
        o.add("("); // open
        o.add('result ${ret}');
        o.add(")"); // close
    }

    
    var fbody:String = '${[for(c in code) '(${Ops.fromInstr(c.op)} ${c.immediates.join(" ")})'].join("\n\t")}';
    
    o.add(' => \n\t ${fbody}');

    o.add("\n)\n"); // close
}
Sys.println(o.toString());
```
Text dump should look like this:
```go
(func (result i32) => 
        (get_global 0)
)
(func (result i64) => 
        (get_global 3)
)
(func (result i32) => 
        (get_global 4)
)
(func (result i64) => 
        (get_global 7)
)
(func (param i32) => 
        (get_local 0)
        (set_global 4)
)
(func (param i64) => 
        (get_local 0)
        (set_global 7)
)
(func (result f32) => 
        (get_global 1)
)
(func (result f64) => 
        (get_global 2)
)
(func (result f32) => 
        (get_global 5)
)
(func (result f64) => 
        (get_global 6)
)
(func (param f32) => 
        (get_local 0)
        (set_global 5)
)
(func (param f64) => 
        (get_local 0)
        (set_global 6)
)
```

### Run Test 
Java
```
java -jar bin/wasp/java/Test.jar
```
C# 
```
#windows
bin/wasp/bin/cs/bin/Test.exe

#unix (wine)
wine bin/wasp/bin/cs/bin/Test.exe
```
C++
```
#windows
bin/wasp/cpp/Test.exe

#unix and darwin
bin/wasp/cpp/Test
```
A `globals.wat` file will be generated from the `globals.wasm` binary

```go
(module
  (type (;0;) (func (result i32)))
  (type (;1;) (func (result i64)))
  (type (;2;) (func (param i32)))
  (type (;3;) (func (param i64)))
  (type (;4;) (func (result f32)))
  (type (;5;) (func (result f64)))
  (type (;6;) (func (param f32)))
  (type (;7;) (func (param f64)))
  (func (;0;) (type 0) (result i32)
    get_global 0)
  (func (;1;) (type 1) (result i64)
    get_global 3)
  (func (;2;) (type 0) (result i32)
    get_global 4)
  (func (;3;) (type 1) (result i64)
    get_global 7)
  (func (;4;) (type 2) (param i32)
    get_local 0
    set_global 4)
  (func (;5;) (type 3) (param i64)
    get_local 0
    set_global 7)
  (func (;6;) (type 4) (result f32)
    get_global 1)
  (func (;7;) (type 5) (result f64)
    get_global 2)
  (func (;8;) (type 4) (result f32)
    get_global 5)
  (func (;9;) (type 5) (result f64)
    get_global 6)
  (func (;10;) (type 6) (param f32)
    get_local 0
    set_global 5)
  (func (;11;) (type 7) (param f64)
    get_local 0
    set_global 6)
  (global (;0;) i32 (i32.const -2))
  (global (;1;) f32 (f32.const 0xc0400000 (;=-3;)))
  (global (;2;) f64 (f64.const 0xc010000000000000 (;=-4;)))
  (global (;3;) i64 (i64.const -5))
  (global (;4;) (mut i32) (i32.const -12))
  (global (;5;) (mut f32) (f32.const 0xc1500000 (;=-13;)))
  (global (;6;) (mut f64) (f64.const 0xc02c000000000000 (;=-14;)))
  (global (;7;) (mut i64) (i64.const -15))
  (export "get-a" (func 0))
  (export "get-b" (func 1))
  (export "get-x" (func 2))
  (export "get-y" (func 3))
  (export "set-x" (func 4))
  (export "set-y" (func 5))
  (export "get-1" (func 6))
  (export "get-2" (func 7))
  (export "get-5" (func 8))
  (export "get-6" (func 9))
  (export "set-5" (func 10))
  (export "set-6" (func 11))
)
```

### Project Status
C# and Java targets are already looking good.

C++ target is still very much WIP, some issues related to `invalid cast` is being fixed.

### Roadmap
* Javascript target
* Hashlink target 
* Neko target
* Eval target**
* Transform project into dynamic libraries in target languages (E.G DLL for C#/.Net, Jar for Java/Kotlin etc)

### Creative Commons
Wasp vector icon gotten freely from [Vecteezy](https://www.vecteezy.com/free-vector/wasp)
