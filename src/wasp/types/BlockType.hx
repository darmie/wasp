package wasp.types;

/**
 * BlockType represents the signature of a structured block
 */
enum abstract BlockType(ValueType) from ValueType to ValueType {
	var BlockTypeEmpty = 0x40;

	public inline function toString():String {
		if (this == BlockTypeEmpty) {
			return "<empty block>";
		}

        return this.toString();
	}
}