package wasp;

import hex.log.HexLog;
import haxe.Int32;
import haxe.io.*;
import wasp.Global.*;
import wasp.exceptions.*;
import wasp.types.*;
import wasp.types.NameType;
import wasp.sections.*;
import wasp.io.*;
import wasp.imports.*;
import binary128.internal.Leb128;
/**
 * ResolveFunc is a function that takes a module name and
 * returns a valid resolved module.
 */
typedef ResolveFunc = (name:String) -> Module;

typedef ImportsT = {
	?funcs:Array<U32>,
	?globals:Int,
	?tables:Int,
	?memories:Int
}

class Module {
	public var version:U32;
	public var sections:Array<Section>;
	public var functionIndexSpace:Array<Function>;
	public var globalIndexSpace:Array<GlobalEntry>;

	public var tableIndexSpace:Array<Array<U32>>;

	public var linearMemoryIndexSpace:Array<Bytes>;

	public var types:SectionTypes;

	public var import_:Imports;

	public var memory:Memories;
	public var function_:Functions;
	public var table:Tables;

	public var global:Globals;
	public var export:Exports;
	public var start:StartFunction;

	public var elements:Elements;

	public var code:Code;
	public var data:Data;
	public var customs:Array<Custom>;

	var imports:ImportsT;

	public function new() {
		sections = [];
		globalIndexSpace = [];
		customs = [];
		functionIndexSpace = [];
		imports = {
			funcs: []
		};
	}

	/**
	 * This is the same as ReadModule, but it only decodes the module without
	 * initializing the index space or resolving imports.
	 * @param r
	 * @return Module
	 */
	public static function decode(r:BytesInput):Module {
		// var reader:ReadPos = new ReadPos(r);
		// reader.curPos = 0;

		var m = new Module();

		var magic = Read.U32(r);

		if (magic != Magic) {
			throw "wasm: Invalid magic number";
		}

		m.version = Read.U32(r);
		if (m.version != Version) {
			throw 'wasm: unknown binary version: ${m.version}';
		}
		
		new SectionsReader(m).readSections(r);

		return m;
	}

	/**
	 * reads a module from the reader r. resolvePath must take a string
	 * and a return a reader to the module pointed to by the string.
	 * @param r
	 * @param resolvePath
	 * @return Module
	 */
	public static function read(r:BytesInput, resolvePath:ResolveFunc):Module {
		var m = decode(r);
		m.linearMemoryIndexSpace = [];
		if (m.table != null) {
			m.tableIndexSpace = new Array<Array<U32>>();
			for(e in m.table.entries) m.tableIndexSpace.push([]);
		}
		if (m.import_ != null) {
			if (m.code == null) {
				m.code = new Code(m);
			}
			m.resolveImports(resolvePath);
		}
		var count = 0;
		for (fn in [m.populateGlobals, m.populateFunctions, m.populateTables, m.populateLinearMemory]) {
			try {
				fn();
				count++;
			} catch (e:Dynamic) {
				throw e;
			}
		}
		HexLog.info('There are ${m.functionIndexSpace.length} entries in the function index space.');
		return m;
	}

	public function resolveImports(resolve:ResolveFunc) {
		if (import_ == null)
			return;

		var modules:Map<String, Module>  = new Map<String, Module>();

		var funcs = 0;
		for (importEntry in import_.entries) {
			var importedModule:Module = null;
			if (modules.exists(importEntry.moduleName)) {
				importedModule = modules.get(importEntry.moduleName);
			} else {
				importedModule = resolve(importEntry.moduleName);
				modules.set(importEntry.moduleName, importedModule);
			}

			if (importedModule.export == null) {
				throw "wasm: imported module has no exports";
			}
			if (!importedModule.export.entries.exists(importEntry.fieldName)) {
				throw new ExportNotFoundErr(importEntry.fieldName, importEntry.moduleName);
			}
			var exportEntry = importedModule.export.entries.get(importEntry.fieldName);
			if (exportEntry.kind != importEntry.type.kind()) {
				throw new KindMismatchError(importEntry.moduleName, importEntry.fieldName, importEntry.type.kind(), exportEntry.kind);
			}

			var index = exportEntry.index;

			switch exportEntry.kind {
				case ExternalFunction:
					{
						var fn = importedModule.getFunction(index);
						if (fn == null) {
							throw new InvalidFunctionIndexError(index);
						}

						var importIndex = cast(importEntry.type, FuncImport).type;

						if (fn.sig.returnTypes.length != types.entries[importIndex].returnTypes.length
							|| fn.sig.paramTypes.length != types.entries[importIndex].paramTypes.length) {
							throw new InvalidImportError(importEntry.moduleName, importEntry.fieldName, importIndex);
						}

						for (i in 0...fn.sig.returnTypes.length) {
							var typ = fn.sig.returnTypes[i];
							if (typ != types.entries[importIndex].returnTypes[i]) {
								throw new InvalidImportError(importEntry.moduleName, importEntry.fieldName, importIndex);
							}
						}

						for (i in 0...fn.sig.paramTypes.length) {
							var typ = fn.sig.paramTypes[i];
							if (typ != types.entries[importIndex].paramTypes[i]) {
								throw new InvalidImportError(importEntry.moduleName, importEntry.fieldName, importIndex);
							}
						}

						functionIndexSpace.push(fn);
						code.bodies.push(fn.body);
						imports.funcs.push(funcs);
						funcs++;
					}
				case ExternalGlobal:
					{
						var glob = importedModule.getGlobal(index);
						if (glob == null) {
							throw new InvalidGlobalIndexError(index);
						}
						if (glob.type.mutable) {
							throw "wasm: cannot import global mutable variable";
						}

						globalIndexSpace.push(glob);
						imports.globals++;
					}
				// In both cases below, index should be always 0 (according to the MVP)
				// We check it against the length of the index space anyway.
				case ExternalTable:
					{
						if (index >= importedModule.tableIndexSpace.length) {
							throw new InvalidTableIndexError(index);
						}
						tableIndexSpace[0] = importedModule.tableIndexSpace[0];
						imports.tables++;
					}

				case ExternalMemory:
					{
						if (index >= importedModule.linearMemoryIndexSpace.length) {
							throw new InvalidLinearMemoryIndexError(index);
						}

						linearMemoryIndexSpace[0] = importedModule.linearMemoryIndexSpace[0];
						imports.memories++;
					}
				default:
					throw new InvalidExternalError(exportEntry.kind);
			}
		}
	}

	public function populateGlobals() {
		if (global == null) {
			return;
		}
		
		globalIndexSpace = globalIndexSpace.concat(global.globals);
		hex.log.HexLog.info('There are ${globalIndexSpace.length} entries in the global index spaces.');
	}

	/**
	 * Functions for populating and looking up entries in a module's index space
	 * More info: http://webassembly.org/docs/modules/#function-index-space
	 */
	public function populateFunctions() {
		if (types == null || function_ == null) {
			return;
		}

		// If present, extract the function names from the custom 'name' section
		var names:NameMap = new NameMap();
		var s = custom(CustomSectionName);
		
		if (s != null) {
			var nSec:NameSection = new NameSection();
			var bi = new BytesInput(s.data);
			nSec.fromWasm(bi);
			var exists = #if cs (nSec.types.ContainsKey(NameFunction)); #else nSec.types.exists(NameFunction); #end
			if (exists && nSec.types[NameFunction].length > 0) {
				var sub = nSec.decode(NameFunction);
				var funcs:FunctionNames = cast sub;
				names = funcs.names;
			}
		}
	
		// If available, fill in the name field for the imported functions
		for (i in 0...functionIndexSpace.length) {
			functionIndexSpace[i].name = names[cast(i, U32)];
		}

		// Add the functions from the wasm itself to the function list
		var numImports = functionIndexSpace.length;
		
		for (codeIndex in 0...function_.types.length) {
			var typeIndex = function_.types[codeIndex];
			
			if (cast(typeIndex, Int) >= types.entries.length) {
				var err:InvalidFunctionIndexError = typeIndex;
				throw err;
			}
			// Create the main function structure
			var nameIndex:U32 = (codeIndex + numImports);
			var fn = new Function(types.entries[cast typeIndex], code.bodies[codeIndex], names[nameIndex]);
			functionIndexSpace.push(fn);
		}
		
		var funcs = [];
		funcs = funcs.concat(imports.funcs);
		funcs = funcs.concat(function_.types);
		function_.types = funcs;
	}

	/**
	 * returns a Function, based on the function's index in
	 * the function index space. Returns nil when the index is invalid
	 * @param i
	 * @return Function
	 */
	public function getFunction(i):Function {
		if (i >= functionIndexSpace.length || i < 0) {
			return null;
		}
		return functionIndexSpace[i];
	}

	public function getGlobal(i):GlobalEntry {
		if (i >= globalIndexSpace.length || i < 0) {
			return null;
		}
		return globalIndexSpace[i];
	}

	public function populateTables() {
		if (table == null || table.entries.length == 0 || elements == null || elements.entries.length == 0) {
			return;
		}
		
		for (elem in elements.entries) {
			// the MVP dictates that index should always be zero, we should probably check this
			if (cast(elem.index, Int) >= tableIndexSpace.length) {
				var err:InvalidTableIndexError = cast elem.index;
				throw err;
			}
			var val = execInitExpr(this, elem.offset);
			var off:Int32 = 0;
			var offset = 0;
			try {
				off = cast val;
				offset = off;
			} catch (e:Dynamic) {
				throw new InvalidValueTypeInitExprError(TInt, Type.typeof(val));
			}
			var table = tableIndexSpace[cast elem.index];
			if (offset + elem.elems.length > table.length) {
				var data = new haxe.ds.Vector<U32>(offset + elem.elems.length).toArray();
				var off = offset;
				for (e in elem.elems) {
					data.insert(off, e);
					off++;
				}
				var i = 0;
				for (t in table) {
					data.insert(i, t);
					i++;
				}

				tableIndexSpace[cast(elem.index, Int)] = data;
			} else {
				for (i in offset...elem.elems.length) {
					for (e in elem.elems) {
						table.insert(i, e);
					}
				}
			}
		}
		hex.log.HexLog.info('There are ${tableIndexSpace.length} entries in the table index space.');
	}

	public function populateLinearMemory() {
		if (data == null || data.entries.length == 0) {
			return;
		}

		for (entry in data.entries) {
			if (entry.index != 0) {
				throw new InvalidTableIndexError(entry.index);
			}

			var val = execInitExpr(this, entry.offset);
			var off:Int32 = 0;
			var offset = 0;
			try {
				off = cast val;
				offset = off;
			} catch (e:Dynamic) {
				throw new InvalidValueTypeInitExprError(TInt, Type.typeof(val));
			}
			var memory = linearMemoryIndexSpace[entry.index];
			if (offset + entry.data.length > memory.length) {
				var data = Bytes.alloc(offset + entry.data.length);
				var off = offset;
				var i = 0;
				while (i < memory.length) {
					data.set(i, memory.get(i));
					i++;
				}
				i = 0;
				while (off < entry.data.length) {
					data.set(off, entry.data.get(i));
					off++;
					i++;
				}
				linearMemoryIndexSpace[entry.index] = data;
			} else {
				var off = offset;
				var i = 0;
				while (off < entry.data.length) {
					memory.set(off, entry.data.get(i));
					off++;
					i++;
				}
			}
		}
	}

	public function getLinearMemoryData(index:Int):Int {
		if (index >= linearMemoryIndexSpace.length) {
			throw new InvalidLinearMemoryIndexError(index);
		}
		return linearMemoryIndexSpace[0].get(index);
	}

	/**
	 * returns a custom section with a specific name, if it exists.
	 * @param name 
	 * @return Custom
	 */
	public function custom(name:String):Custom {
		for(s in customs){
			if(s.name == name){
				return s;
			}
		}
		return null;
	}
}