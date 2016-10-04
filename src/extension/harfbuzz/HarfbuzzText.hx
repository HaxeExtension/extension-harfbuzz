package extension.harfbuzz;

import openfl.display.Sprite;

class HarfbuzzText extends Sprite{

	///////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////

	private static var cachedRenderer:OpenflHarfbuzzRenderer = null;
	private static var shouldCache:Bool = false;
	private static var cacheText:String = "XQ.";
	public static inline var LEFT:String = 'left';
	public static inline var RIGHT:String = 'right';
	public static inline var CENTER:String = 'center';

	///////////////////////////////////////////////////////////////////////////
	
	public static function enableCache(text:String){
		cacheText = text+" \r\t\n";
		shouldCache = true;
		cachedRenderer = null;
	}

	///////////////////////////////////////////////////////////////////////////

	public static function disableCache(){
		shouldCache = false;
		cacheText = "XQ.";
		cachedRenderer = null;
	}

	///////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////////////////////

	private var boxWidth:Float;
	private var renderedText:HarfbuzzSprite;
	public var quality:Float;
	public var color:Int;
	public var align:String;
	public var text(default,set):String = '';
	public var size(default,set):Int;
	public var font:String;

	///////////////////////////////////////////////////////////////////////////

	public function new(font:String, size:Float=12, color:Int=0x000000, align=LEFT, width:Float=400, quality:Float = 1){
		super();
		this.quality = quality;
		this.font  = font;
		this.size  = Math.round(size);
		this.color = color;
		this.align = align;
		this.boxWidth = width;
		renderedText = null;
	}

	///////////////////////////////////////////////////////////////////////////

	private function realign(){
		if (renderedText == null) return;
		if (align == CENTER) renderedText.x = Math.round((boxWidth-renderedText.textWidth/quality)/2-renderedText.minX/quality);
		if (align == LEFT)   renderedText.x = 0;
		if (align == RIGHT)  renderedText.x = Math.round(boxWidth-renderedText.textWidth/quality);
	}

	///////////////////////////////////////////////////////////////////////////

	public function getTextWidth():Float {
		if(renderedText == null) return 0;
		return renderedText.textWidth/quality;
	}

	///////////////////////////////////////////////////////////////////////////

	override private function set_width(width:Float):Float{
		this.boxWidth = width;
		realign();
		return width;
	}

	///////////////////////////////////////////////////////////////////////////

	override private function get_width() return boxWidth;

	///////////////////////////////////////////////////////////////////////////

	override private function get_height():Float {
	 	if(renderedText == null) return 0;
	 	return renderedText.boxHeight/quality;
	}

	///////////////////////////////////////////////////////////////////////////

	private function set_size(size:Int):Int {
		if(size == this.size) return size;
		this.size = size;
		if(text!=null && text!="") set_text(text);
		return size;
	}

	///////////////////////////////////////////////////////////////////////////

	private function createText(dictionary:String):HarfbuzzSprite{
		var renderer:OpenflHarfbuzzRenderer = cachedRenderer;
		if(renderer == null) renderer = new OpenflHarfbuzzRenderer(font, Math.round(size*quality), color, cacheText+text);
		if(shouldCache) cachedRenderer = renderer;
		
		var spr:HarfbuzzSprite = renderer.renderText( text, boxWidth*quality );
		spr.scaleX = spr.scaleY = 1/quality;
		return spr;
	}

	///////////////////////////////////////////////////////////////////////////

	private function set_text(text:String):String {
		this.text=text;
		if(renderedText != null) this.removeChild(renderedText);
		renderedText = createText(text);
		this.addChild(renderedText);
		realign();
		return text;
	}

	///////////////////////////////////////////////////////////////////////////

}