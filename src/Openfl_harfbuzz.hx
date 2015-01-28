package;

typedef FTFace = Dynamic;
typedef HBBuffer = Dynamic;

@:build(ShortCuts.mirrors())
@CPP_DEFAULT_LIBRARY("openfl_harfbuzz")
@CPP_PRIMITIVE_PREFIX("openfl_harfbuzz")
class Openfl_harfbuzz {

	@CPP public static function init() : Void {}
	@CPP public static function loadFontFaceFromFile(filePath : String, faceIndex : Int = 0) : FTFace { return null; };
	@CPP public static function setFontSize(face : FTFace, size : Int) : Void {};
	@CPP public static function createBuffer(direction : TextDirection, script : TextScript, language : String, text : String) : HBBuffer { return null; }
	@CPP public static function loadGlyphsForBuffer(face : FTFace, buffer : HBBuffer) : Void {};

}
