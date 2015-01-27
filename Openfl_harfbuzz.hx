package;

@:build(ShortCuts.mirrors())
@CPP_DEFAULT_LIBRARY("openfl_harfbuzz")
@CPP_PRIMITIVE_PREFIX("openfl_harfbuzz")
class Openfl_harfbuzz {

	@CPP public static function init() : Void {}
	@CPP public static function loadFontFaceFromFile(filePath : String, faceIndex : Int = 0) : Bool { return false; };
	@CPP public static function setFontSize(size : Int) : Void {};

}
