package extension.harfbuzz;

import openfl.display.BitmapData;
import openfl.display.Graphics;
import openfl.display.Sprite;
import openfl.display.Tilesheet;
import openfl.geom.Rectangle;

class TilesRenderer {

	var tilesheet : Tilesheet;
	var glyphIds : Map<Int, Int>;	// Codepoint -> tile id
	var glyphRects : Map<Int, Rectangle>;	// Codepoint -> tile id
	var blitList : Array<Float>;

	public function new(
		atlas : BitmapData,
		glyphs : Array<{ codepoint : Int, rect : Rectangle }>) {

		tilesheet = new Tilesheet(atlas);
		glyphIds = new Map();
		glyphRects = new Map();
		blitList = [];

		for (i in 0...glyphs.length) {
			var g = glyphs[i];
			glyphIds.set(g.codepoint, i);
			glyphRects.set(g.codepoint, g.rect);
			tilesheet.addTileRect(g.rect);
		}

	}

	public function render(
		textWidth : Float,
		textHeight : Float,
		glyphList : Array<{ codepoint : Int, x : Float, y : Float }>) : HarfbuzzSprite {

		blitList = [];
		
		var minY:Float=5000000;
		var minX:Float=5000000;
		var maxY:Float=-5000000;
		var maxX:Float=-5000000;
		for (g in glyphList) {
			blitList.push(g.x);
			blitList.push(g.y);
			blitList.push(glyphIds[g.codepoint]);
			blitList.push(1);
			blitList.push(1);
			blitList.push(1);
			var rect = glyphRects[g.codepoint];
			if(minY>g.y) minY=g.y;
			if(minX>g.x) minX=g.x;
			if(maxY<g.y+rect.height) maxY=g.y+rect.height;
			if(maxX<g.x+rect.width) maxX=g.x+rect.width;
		}

		var spr = new HarfbuzzSprite(textWidth, textHeight+minY, minX, minY, maxX, maxY);
		tilesheet.drawTiles(spr.graphics, blitList, true, Graphics.TILE_RGB);
		return spr;
	}

}
