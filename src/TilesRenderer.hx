
package ;

import openfl.display.BitmapData;
import openfl.display.Graphics;
import openfl.display.Sprite;
import openfl.display.Tilesheet;
import openfl.geom.Rectangle;

class TilesRenderer {

	var tilesheet : Tilesheet;
	var glyphIds : Map<Int, Int>;	// Codepoint -> tile id
	var blitList : Array<Float>;

	public function new(
		atlas : BitmapData,
		glyphs : Array<{ codepoint : Int, rect : Rectangle }>) {

		tilesheet = new Tilesheet(atlas);
		glyphIds = new Map();
		blitList = [];

		for (i in 0...glyphs.length) {
			var g = glyphs[i];
			glyphIds.set(g.codepoint, i);
			tilesheet.addTileRect(g.rect);
		}

	}

	public function render(
		textWidth : Float,
		textHeight : Float,
		glyphList : Array<{ codepoint : Int, x : Float, y : Float }>,
		colorR : Float,
		colorG : Float,
		colorB : Float ) : Sprite {

		var spr = new Sprite();
		var gfx = spr.graphics;
		blitList = [];
		
		for (g in glyphList) {
			blitList.push(g.x);
			blitList.push(g.y);
			blitList.push(glyphIds[g.codepoint]);
			blitList.push(colorR);
			blitList.push(colorG);
			blitList.push(colorB);
		}
		
		gfx.clear();

		tilesheet.drawTiles(gfx, blitList, true, Graphics.TILE_RGB);

		gfx.beginFill(0, 0.0);
		gfx.drawRect(0, 0, textWidth, textHeight);
		gfx.endFill();

		return spr;

	}

}
