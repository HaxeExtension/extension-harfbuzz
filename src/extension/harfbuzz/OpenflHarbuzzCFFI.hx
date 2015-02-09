package extension.harfbuzz;

typedef FTFace = Dynamic;
typedef HBBuffer = Dynamic;

typedef GlyphRect = {
	codepoint : Int,
	x : Int,
	y : Int,
	width : Int,
	height : Int,
	bitmapLeft : Int,
	bitmapTop : Int,
	bearingX : Float,
	bearingY : Float,
	advanceX : Float
}

typedef GlyphAtlas = {
	width : Int,
	height : Int,
	bmpData : Array<Int>,
	glyphRects : Array<GlyphRect>
}

typedef Point = {
	var x : Float;
	var y : Float;
}

typedef FaceMetrics = {
	ascender : Int,
	descender : Int,
	height : Int,
	xMin : Float,
	yMin : Float,
	xMax : Float,
	yMax : Float
}

typedef PosInfo = {
	var codepoint : Int;
	var advance : Point;
	var offset : Point;
}

@:build(ShortCuts.mirrors())
@CPP_DEFAULT_LIBRARY("openfl_harfbuzz")
@CPP_PRIMITIVE_PREFIX("openfl_harfbuzz")
class OpenflHarbuzzCFFI {

	@CPP public static function init() : Void {}
	@CPP public static function loadFontFaceFromFile(filePath : String, faceIndex : Int = 0) : FTFace;
	@CPP public static function setFontSize(face : FTFace, size : Int) : Void;
	@CPP public static function createBuffer(direction : TextDirection, script : TextScript, language : String, text : String) : HBBuffer;
	@CPP public static function createGlyphAtlas(face : FTFace, buffer : HBBuffer) : GlyphAtlas;
	@CPP public static function layoutText(face : FTFace, buffer : HBBuffer) : Array<PosInfo>;
	@CPP public static function getFaceMetrics(face : FTFace) : FaceMetrics;

}
