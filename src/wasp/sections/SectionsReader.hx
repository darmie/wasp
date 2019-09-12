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

	public function readSections(r:BytesInput) {
		while (true) {
			var done = readSection(r);
			if (done)
				return;
		}
	}

	public function readSection(r:BytesInput):Bool {
		try {
			var m = this.m;
			hex.log.HexLog.info("Reading section ID");
			var id = r.readByte();

			if (id != SectionIDCustom) {
				if (id <= lastSecOrder) {
					throw "wasm: sections must occur at most once and in the prescribed order";
				}

				lastSecOrder = id;
			}

			var s = new RawSection();
			s.id = id;

			hex.log.HexLog.info("Reading payload length");

			var payloadDataLen = Leb128.readUint32(r);

			hex.log.HexLog.info('Section payload length: $payloadDataLen');
		
			s.start = r.position;
			var sectionBytes = Bytes.alloc(payloadDataLen);
			r.readFullBytes(sectionBytes, 0, payloadDataLen);
			var sectionReader = new BytesInput(sectionBytes); //new LimitReader(new TeeReader(r, sectionBytes), payloadDataLen);
		

			var sec:Section = null;
			switch s.id {
				case SectionIDCustom:
					{
						hex.log.HexLog.info("section custom");
						var cs = new Custom();
						m.customs.push(cs);
						sec = cs;
					}
				case SectionIDType:
					{
						hex.log.HexLog.info("section type");
						m.types = new SectionTypes();
						sec = m.types;
					}
				case SectionIDImport:
					{
						hex.log.HexLog.info("section import");
						m.import_ = new Imports();
						sec = m.import_;
					}
				case SectionIDFunction:
					{
						hex.log.HexLog.info("section function");
						m.function_ = new Functions();
						sec = m.function_;
					}
				case SectionIDTable:
					{
						hex.log.HexLog.info("section table");
						m.table = new Tables();
						sec = m.table;
					}
				case SectionIDMemory:
					{
						hex.log.HexLog.info("section memory");
						m.memory = new Memories();
						sec = m.memory;
					}
				case SectionIDGlobal:
					{
						hex.log.HexLog.info("section global");
						m.global = new Globals();
						sec = m.global;
					}
				case SectionIDExport:
					{
						hex.log.HexLog.info("section export");
						m.export = new Exports();
						sec = m.export;
					}
				case SectionIDStart:
					{
						hex.log.HexLog.info("section start");
						m.start = new StartFunction();
						sec = m.start;
					}
				case SectionIDElement:
					{
						hex.log.HexLog.info("section element");
						m.elements = new Elements();
						sec = m.elements;
					}
				case SectionIDCode:
					{
						hex.log.HexLog.info("section code");
						m.code = new Code(m);
						sec = m.code;
					}
				case SectionIDData:
					{
						hex.log.HexLog.info("section data");
						m.data = new Data();
						sec = m.data;
					}
				default:
					throw new InvalidSectionIDError(s.id);
			}
			
			sec.readPayload(sectionReader);
		
			s.end = r.position;
			s.bytes = sectionBytes;
			
			sec = s;
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
                return true;
        }
	}
}