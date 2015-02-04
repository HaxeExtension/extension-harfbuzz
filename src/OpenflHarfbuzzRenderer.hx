package;

import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import OpenflHarbuzzCFFI;

class OpenflHarfbuzzRenderer {

	static var harfbuzzIsInited = false;

	var direction : TextDirection;
	var script : TextScript;
	var language : String;
	var lineHeight : Float;

	var face : FTFace;
	var renderer : TilesRenderer;
	var glyphs : Map<Int, GlyphRect>;

	public function new(
			ttfPath : String,
			textSize : Int,
			direction : TextDirection,
			script : TextScript,
			language : String,
			text : String) {

		this.direction = direction;
		this.script = script;
		this.language = language;
		this.lineHeight = textSize;

		if (!harfbuzzIsInited) {
			OpenflHarbuzzCFFI.init();
		}

		face = OpenflHarbuzzCFFI.loadFontFaceFromFile(ttfPath);
		OpenflHarbuzzCFFI.setFontSize(face, textSize);

		var glyphAtlasResult = OpenflHarbuzzCFFI.createGlyphAtlas(face, createBuffer(text));
		var glyphsBmp = new BitmapData(glyphAtlasResult.width, glyphAtlasResult.height);
		trace(glyphsBmp.width + " " + glyphsBmp.height);

		for (i in 0...glyphAtlasResult.bmpData.length) {
			var pixel = glyphAtlasResult.bmpData[i];
			glyphsBmp.setPixel32(i%glyphsBmp.width, Std.int(i/glyphsBmp.width), pixel);
		}

		glyphs = new Map();
		var glyphsRects = new Array<{ codepoint : Int, rect : Rectangle }>();
		for (rect in glyphAtlasResult.glyphRects) {
			glyphs[rect.codepoint] = rect;
			glyphsRects.push({ codepoint : rect.codepoint, rect : new Rectangle(rect.x, rect.y, rect.width, rect.height) });
		}

		renderer = new TilesRenderer(glyphsBmp, glyphsRects);

	}

	function createBuffer(text : String) : HBBuffer {
		return OpenflHarbuzzCFFI.createBuffer(direction, script, language, text);
	}

	// Splits text into words containging the trailing spaces ("a b c"=["a ", "b ", "c "])
	function split(text : String) : Array<String> {
		var ret = text.split(" ");
		for (i in 0...ret.length) {
			ret[i] = ret[i] + " ";
		}
		return ret;
	}

	function layouWidth(layout : Array<PosInfo>) : Float {
		var xPos = 0.0;
		for (posInfo in layout) {
			xPos += posInfo.advance.x / (100/64);	// 100/64 = 1.5625 = Magic!
		}
		return xPos;
	}

	function renderWords(words : Array<String>) : Array<Array<PosInfo>> {
		var ret = [];
		for (word in words) {
			ret.push(OpenflHarbuzzCFFI.layoutText(face, createBuffer(word)));
		}
		return ret;
	}

	public function renderText(text : String, width : Float, color : Int) : Sprite {

		var renderList = new Array<{ codepoint : Int, x : Float, y : Float }>();
		var words = renderWords(split(text));

		var lineNumber = 1;
		var maxLineWidth = 400;
		var xPosBase = 0.0;
		var yPosBase = lineNumber*lineHeight;

		for (word in words) {

			var wordWidth = layouWidth(word);

			if (xPosBase>0 && xPosBase+wordWidth>width) {
				xPosBase = 0;
				lineNumber++;
				yPosBase = lineNumber*lineHeight;
			}

			var xPos = xPosBase;
			var yPos = yPosBase;

			for (posInfo in word) {
				var g = glyphs[posInfo.codepoint];
				var dstX = Std.int(xPos + posInfo.offset.x + g.bitmapLeft);
				var dstY = Std.int(yPos + posInfo.offset.y - g.bitmapTop);
				renderList.push({ codepoint : g.codepoint, x : dstX, y : dstY });
				xPos += posInfo.advance.x / (100/64);	// 100/64 = 1.5625 = Magic!
				yPos += posInfo.advance.y / (100/64);
			}

			xPosBase += wordWidth;

		}

		return renderer.render(width, (lineNumber)*lineHeight, renderList, ((color>>16)&0xff)/255.0, ((color>>8)&0xff)/255.0, (color&0xff)/255.0);

		/*
		var currentWord = "";
		var layout = [];

		layout = OpenflHarbuzzCFFI.layoutText(face, createBuffer(currentWord));


		for (posInfo in layout) {

			var g = glyphs[posInfo.codepoint];
			
			var dstX = Std.int(xPos + posInfo.offset.x + g.bitmapLeft);
			var dstY = Std.int(yPos + posInfo.offset.y - g.bitmapTop);

			renderList.push({ codepoint : g.codepoint, x : dstX, y : dstY });

			xPos += posInfo.advance.x / (100/64);	// 100/64 = 1.5625 = Magic!
			yPos += posInfo.advance.y / (100/64);

		}

		return renderer.render(lineHeight, renderList, ((color>>16)&0xff)/255.0, ((color>>8)&0xff)/255.0, (color&0xff)/255.0);
		*/
	}

}
