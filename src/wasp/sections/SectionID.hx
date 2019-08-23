package wasp.sections;

enum abstract SectionID(Int) from Int to Int {
	var SectionIDCustom = 0;
	var SectionIDType = 1;
	var SectionIDImport = 2;
	var SectionIDFunction = 3;
	var SectionIDTable = 4;
	var SectionIDMemory = 5;
	var SectionIDGlobal = 6;
	var SectionIDExport = 7;
	var SectionIDStart = 8;
	var SectionIDElement = 9;
	var SectionIDCode = 10;
	var SectionIDData = 11;

	public inline function toString() {
		var map = [
			SectionIDCustom => "custom", SectionIDType => "type", SectionIDImport => "import", SectionIDFunction => "function", SectionIDTable => "table",
			SectionIDMemory => "memory", SectionIDGlobal => "global", SectionIDExport => "export", SectionIDStart => "start", SectionIDElement => "element",
			SectionIDCode => "code", SectionIDData => "data",
		];

        return map.get(this);
	}
}