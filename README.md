# extension-harfbuzz
Native Harfbuzz based OpenFL extension for text rendering

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
			TextDirection.LeftToRight,
			TextScript.ScriptCommon,
			"en",
			"Abstract."
		);
		
		var bmp2 = renderer2.renderText("Abstract.", 0x009922);
		bmp2.x = 20;
		bmp2.y = 300;
		addChild(bmp2);

		Lib.current.addChild(this);

	}


}
```
