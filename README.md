# openfl-harfbuzz
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
			80,
			TextDirection.RightToLeft,
			TextScript.ScriptArabic,
			"ar",
			"مرحبا أصدقاء كيف هي؟"
		);

		var bmp = new Bitmap(renderer.renderText("مرحبا أصدقاء كيف هي؟"));
		bmp.x = 20;
		bmp.y = 20;
		addChild(bmp);
		
		var renderer2 = new OpenflHarfbuzzRenderer(
			"assets/amiri-regular.ttf",
			60,
			TextDirection.LeftToRight,
			TextScript.ScriptCommon,
			"en",
			"Lorem impsum."
		);
		
		var bmp2 = new Bitmap(renderer2.renderText("Lorem impsum."));
		bmp2.x = 20;
		bmp2.y = 300;
		addChild(bmp2);

		Lib.current.addChild(this);

	}


}

```
