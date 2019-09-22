# Wasp  ![](https://travis-ci.org/darmie/wasp.svg?branch=master)

WebAssembly Utility for Haxe

 * Dissasemble `.wasm` to `.wast` and Haxe specific data representations.
 * Validate `.wasm` [WIP]


__WASP__ is based on portions of [Wagon](https://github.com/go-interpreter/wagon), a WebAssembly interpreter in [Go](https://golang.org), and ported to the [Haxe](https://haxe.org) programming language.

### Dependencies

 * [Haxe](https://haxe.org/)
 * [Binary128](https://github.com/darmie/binary128)

Run `haxelib install all` to install the dependencies.

### Compile

```
haxe build.hxml
```

