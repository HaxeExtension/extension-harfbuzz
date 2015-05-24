package extension.harfbuzz;

import openfl.display.Sprite;

class HarfbuzzSprite extends Sprite{

	public var boxWidth(default,null):Float;
	public var boxHeight(default,null):Float;

	public function new(boxWidth:Float, boxHeight:Float){
		super();
		this.boxWidth = boxWidth;
		this.boxHeight = boxHeight;
	}

}