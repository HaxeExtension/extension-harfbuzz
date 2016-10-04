package extension.harfbuzz;

import openfl.display.Tilemap;
import openfl.display.Tileset;

class HarfbuzzSprite extends Tilemap{

	public var boxWidth(default,null):Float;
	public var boxHeight(default,null):Float;
	public var minX(default,null):Float;
	public var minY(default,null):Float;
	public var maxX(default,null):Float;
	public var maxY(default,null):Float;
	public var textWidth(default,null):Float;

	public function new(boxWidth:Float, boxHeight:Float, minX:Float, minY:Float, maxX:Float, maxY:Float, tileset:Tileset){
		super(Math.ceil(boxWidth),Math.ceil(boxHeight),tileset);
		this.boxWidth = boxWidth;
		this.boxHeight = boxHeight;
		this.minX = minX;
		this.minY = minY;
		this.maxX = maxX;
		this.maxY = maxY;
		this.textWidth = maxX-minX;
	}

}