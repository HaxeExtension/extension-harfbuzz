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

	public function renderText(text : String, color : Int) : Sprite {

		var layout = OpenflHarbuzzCFFI.layoutText(face, createBuffer(text));

		var minTotalX = 9999.0;
		var maxTotalX = -9999.0;
		var minTotalY = 9999.0;
		var maxTotalY = -9999.0;

		var xPos = 0.0;
		var yPos = 0.0;

		if (layout.length==0) {
			minTotalX = maxTotalX = minTotalY = maxTotalY = 0;
		}

		for (posInfo in layout) {

			var g = glyphs[posInfo.codepoint];

			var minX = xPos + posInfo.offset.x;
			var maxX = minX + g.width;

			var minY = yPos + posInfo.offset.y - g.bitmapTop;
			var maxY = minY + g.height;

			minTotalX = Math.min(minTotalX, minX);
			minTotalY = Math.min(minTotalY, minY);
			maxTotalX = Math.max(maxTotalX, maxX);
			maxTotalY = Math.max(maxTotalY, maxY);

			xPos += posInfo.advance.x / (100/64) + g.bitmapLeft;	// Not sure if correct, but it works...
			yPos += posInfo.advance.y;

		}

		var bmpData = new BitmapData(Std.int(maxTotalX-minTotalX), Std.int(maxTotalY-minTotalY));

		var xPos = 0.0;
		var yPos = 0.0;

		var renderList = new Array<{ codepoint : Int, x : Float, y : Float }>();
		for (posInfo in layout) {

			var g = glyphs[posInfo.codepoint];
			
			var dstX:Int = Std.int(xPos + posInfo.offset.x + g.bitmapLeft);
			var dstY:Int = Std.int(yPos + posInfo.offset.y - g.bitmapTop - minTotalY);

			renderList.push({ codepoint : g.codepoint, x : dstX, y : dstY });

			xPos += posInfo.advance.x / (100/64);	// 100/64 = 1.5625 = Magic!
			yPos += posInfo.advance.y;

		}

		return renderer.render(renderList, ((color>>16)&0xff)/255.0, ((color>>8)&0xff)/255.0, (color&0xff)/255.0);

	}

}
