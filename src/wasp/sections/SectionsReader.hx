package wasp.sections;

import wasp.io.*;
import wasp.Module;
import haxe.io.*;
import wasp.types.*;
import wasp.sections.SectionID;
import binary128.internal.Leb128;
import wasp.exceptions.*;

class SectionsReader {
	private var lastSecOrder:UInt;
	private var m:Module;

	public function new(_m:Module) {
		m = _m;
	}

	public function readSections(r:ReadPos) {
		while (true) {
			var done = readSection(r);
			if (done)
				return;
		}
	}

	public function readSection(r:ReadPos):Bool {
		try {
			var m = this.m;

			Console.log("Reading section ID");
			var id = r.readByte();

			if (id != SectionIDCustom) {
				if (id <= lastSecOrder) {
					throw "wasm: sections must occur at most once and in the prescribed order";
				}

				lastSecOrder = id;
			}

			var s = new RawSection();
			s.id = id;

			Console.log("Reading payload length");

			var payloadDataLen = Leb128.readUint32(r);

			Console.log('Section payload length: $payloadDataLen');

			s.start = r.curPos;

			var sectionBytes = new BytesOutput();

			var sectionReder = new LimitReader(new TeeReader(r, sectionBytes), payloadDataLen);

			var sec:Section = null;

			switch s.id {
				case SectionIDCustom:
					{
						Console.log("section custom");
						var cs = new Custom();
						m.customs.push(cs);
						sec = cs;
					}
				case SectionIDType:
					{
						Console.log("section type");
						m.types = new SectionTypes();
						sec = m.types;
					}
				case SectionIDImport:
					{
						Console.log("section import");
						m.import_ = new Imports();
						sec = m.import_;
					}
				case SectionIDFunction:
					{
						Console.log("section function");
						m.function_ = new Functions();
						sec = m.function_;
					}
				case SectionIDTable:
					{
						Console.log("section table");
						m.table = new Tables();
						sec = m.table;
					}
				case SectionIDMemory:
					{
						Console.log("section memory");
						m.memory = new Memories();
						sec = m.memory;
					}
				case SectionIDGlobal:
					{
						Console.log("section global");
						m.global = new Globals();
						sec = m.global;
					}
				case SectionIDExport:
					{
						Console.log("section export");
						m.export = new Exports();
						sec = m.export;
					}
				case SectionIDStart:
					{
						Console.log("section start");
						m.start = new StartFunction();
						sec = m.start;
					}
				case SectionIDElement:
					{
						Console.log("section element");
						m.elements = new Elements();
						sec = m.elements;
					}
				case SectionIDCode:
					{
						Console.log("section code");
						m.code = new Code();
						sec = m.code;
					}
				case SectionIDData:
					{
						Console.log("section data");
						m.data = new Data();
						sec = m.data;
					}
				default:
					throw new InvalidSectionIDError(s.id);
			}

			sec.readPayload(sectionReder);
			s.end = r.curPos;
			s.bytes = sectionBytes.getBytes();

			switch s.id {
				case SectionIDCode:
					{
						var s = m.code;
						if (m.function_ == null || m.function_.types.length == 0) {
							throw new MissingSectionError(SectionIDFunction);
						}

						if (m.function_.types.length != s.bodies.length) {
							throw "wasm: the number of entries in the function and code section are unequal";
						}

						if (m.types == null) {
							throw new MissingSectionError(SectionIDType);
						}

						for (i in 0...s.bodies.length) {
							s.bodies[i].module = m;
						}
					}
				case _:
			}

			m.sections.push(sec);

			return false;
		} catch (e:haxe.io.Eof) {
                return false;
        }
	}
}