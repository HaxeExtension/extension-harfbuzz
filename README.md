# extension-harfbuzz
Native Harfbuzz extension for text rendering on Lime Legacy & NME.

Example:
```haxe
package;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.Lib;

class Main extends Sprite {


	public function new () {

		super ();
		
		var renderer = new OpenflHarfbuzzRenderer(
			"assets/amiri-regular.ttf",
			90,
			0x009922, // color
			TextDirection.RightToLeft,
			TextScript.ScriptArabic,
			"ar",
			"مرحبا أصدقاء كيف هي؟"
		);

		var bmp = renderer.renderText(
			"مرحبا أصدقاء كيف هي؟",
			0xe57d00);
		
		bmp.x = 20;
		bmp.y = 20;
		addChild(bmp);
		
		var renderer2 = new OpenflHarfbuzzRenderer(
			"assets/amiri-regular.ttf",
			80,
			0xFF0000, // color
			TextDirection.LeftToRight,
			TextScript.ScriptCommon,
			"en",
			"Abstract."
		);
		
		var bmp2 = renderer2.renderText("Abstract.", 300); // 300px
		bmp2.x = 20;
		bmp2.y = 300;
		addChild(bmp2);

		Lib.current.addChild(this);

	}


}
```

Also, this extension brings an easy-to-use class named HarfbuzzText.

Example:
```haxe

function placeText() {

	var font = 'fonts/subset-cj-BabelStoneHan.ttf';
	var size = 28;
	var color = 0x009922;
	var align = HarfbuzzText.LEFT;
	var quality = 1;

	var label=new HarfbuzzText(font, size, color, align, quality);
	label.width = 400;
	label.text = 'Hello world!';

	addChild(label);

}

```