package extension.harfbuzz;

import openfl.display.BitmapData;
import openfl.display.Graphics;
import openfl.display.Sprite;
import openfl.display.Tilemap;
import openfl.display.Tileset;
import openfl.display.Tile;
import openfl.geom.Rectangle;

class TilesRenderer {

	var tilemap : Tilemap;
	var tileset : Tileset;
	var glyphIds : Map<Int, Int>;	// Codepoint -> tile id
	var blitList : Array<Tile>;

	public function new(
		atlas : BitmapData,
		glyphs : Array<{ codepoint : Int, rect : Rectangle }>) {

		tileset = new Tileset(atlas);
		glyphIds = new Map();
		blitList = [];

		for (i in 0...glyphs.length) {
			var g = glyphs[i];
			glyphIds.set(g.codepoint, i);
			tileset.addRect(g.rect);
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
			var id:Int = glyphIds[g.codepoint];
			var rect = tileset.getRect(id);
			blitList.push(new Tile(id, g.x, g.y, 1, 1, 0));
			if(minY>g.y) minY=g.y;
			if(minX>g.x) minX=g.x;
			if(maxY<g.y+rect.height) maxY=g.y+rect.height;
			if(maxX<g.x+rect.width) maxX=g.x+rect.width;
		}

		var spr = new HarfbuzzSprite(textWidth, textHeight+minY, minX, minY, maxX, maxY, tileset);
		spr.addTiles(blitList);
		return spr;
	}

}
