package extension.harfbuzz;

import extension.harfbuzz.OpenflHarbuzzCFFI;
import extension.harfbuzz.TextScript;
import haxe.Utf8;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.Lib;
import openfl.utils.ByteArray;

class OpenflHarfbuzzRenderer {

	static var harfbuzzIsInited = false;

	var direction : TextDirection;
	var script : TextScript;
	var language : String;
	var lineHeight : Float;

	var face : FTFace;
	var renderer : TilesRenderer;
	var glyphs : Map<Int, GlyphRect>;

	public function new(
			fontName : String,	// Font path or Openfl Asset ID
			textSize : Int,
			text : String,
			language : String = "",
			script : TextScript = null,
			direction : TextDirection = null) {

		if (script==null) {
			script = ScriptIdentificator.identify(text);
		}
		this.script = script;

		if (direction==null) {
			direction = TextScriptTools.isRightToLeft(script) ? RightToLeft : LeftToRight;
		}
		this.direction = direction;

		this.language = language;
		this.lineHeight = textSize;

		if (!harfbuzzIsInited) {
			OpenflHarbuzzCFFI.init();
		}

		if (sys.FileSystem.exists(fontName)) {
			face = OpenflHarbuzzCFFI.loadFontFaceFromFile(fontName);
		} else {
			face = OpenflHarbuzzCFFI.loadFontFaceFromMemory(openfl.Assets.getBytes(fontName).getData());
		}
		
		OpenflHarbuzzCFFI.setFontSize(face, textSize);

		var glyphAtlasResult = OpenflHarbuzzCFFI.createGlyphAtlas(face, createBuffer(text));
		var glyphsBmp = new BitmapData(glyphAtlasResult.width, glyphAtlasResult.height);

		var rect = new Rectangle(0, 0, glyphsBmp.width, glyphsBmp.height);
		var ct = new openfl.geom.ColorTransform(1,1,1,1,255,255,255,0);
		glyphsBmp.setVector(rect, glyphAtlasResult.bmpData);
		glyphsBmp.colorTransform(rect, ct);

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

	function isPunctuation(char:String) {
		return
			char == '.' ||
			char == ',' ||
			char == ':' ||
			char == ';' ||
			char == '-' ||
			char == '_' ||
			char == '[' ||
			char == ']' ||
			char == '(' ||
			char == ')';
	}


	private function isSpace(i:Int){
		return i==9 || i==10 || i==11 || i==12 || i==13 || i==32;
	}

	// Splits text into words containging the trailing spaces ("a b c"=["a ", "b ", "c "])
	function split(text : String) : Array<String> {
		var ret = [];
		var currentWord:Utf8 = null;
		var l:Int = Utf8.length(text);
		Utf8.iter(text,function(cCode:Int){
			if (cCode==13) return;
			if (isSpace(cCode)) {
				if(currentWord != null) ret.push(currentWord.toString());
				currentWord = new Utf8();
				currentWord.addChar(cCode);
				ret.push(currentWord.toString());
				currentWord = null;
				return;
			}
			if(currentWord==null) currentWord = new Utf8();
			currentWord.addChar(cCode);		
		});
		if (currentWord != null) {
			ret.push(currentWord.toString());
		}
		return ret;
	}

	function layouWidth(layout : Array<PosInfo>) : Float {
		var xPos = 0.0;
		for (posInfo in layout) {
			xPos += posInfo.advance.x / (100/64);	// 100/64 = 1.5625 = Magic!
		}
		return xPos;
	}

	function isEndOfLine(xPos : Float, wordWidth : Float, lineWidth : Float) {
		if (direction == LeftToRight) {
			return (xPos>0.0 && xPos+wordWidth>lineWidth);
		} else {	// RightToLeft
			return (xPos<lineWidth&& xPos-wordWidth<0.0);
		}
	}

	private function invertString(s:String):String{
		var l:Int = Utf8.length(s);
		var res:Utf8 = new Utf8();
		for(i in -l+1...1) res.addChar(Utf8.charCodeAt(s,-i));
		return res.toString();
	}

	// if "text" is in RtoL script, invert non-RtoL substrings
	function preProcessText(text : String) {
		var isRtoL:Bool = TextScriptTools.isRightToLeft(script);

		var res:StringBuf = new StringBuf();
		var char:String = '';
		var phrase:String = '';
		var spaces:String = '';
		var word:String = '';
		var length:Int = text.length;

		for(i in 0 ... length){
			char = text.charAt(i);
			if(char=="\r") continue;
			if(isPunctuation(char) || StringTools.isSpace(text,i)) {
				if(word == '') {
					spaces += char;
					continue;
				}
				if(char == "\n" || TextScriptTools.isRightToLeft(ScriptIdentificator.identify(word,script)) == isRtoL){
					res.add(invertString(phrase));
					res.add(spaces);
					res.add(word);
					res.add(char);
					spaces = phrase = word = '';
				} else {
					if(phrase == '') {
						res.add(spaces);
						spaces = '';
					}
					phrase += spaces+word;
					word = '';
					spaces = char;
				}
				continue;
			}
			word+=char;
		}

		if(word != '' && TextScriptTools.isRightToLeft(ScriptIdentificator.identify(word,script)) != isRtoL) {
			phrase += spaces+word;
			spaces = word = '';
		}
		res.add(invertString(phrase));
		res.add(spaces);
		res.add(word);
		return res.toString();
	}

	public function renderText(text : String, lineWidth : Float, color : Int) : HarfbuzzSprite {

		text = preProcessText(text);

		var renderList = new Array<{ codepoint : Int, x : Float, y : Float }>();
		var words = split(text);

		var lineNumber : Int = 1;
		var maxLineWidth = 400;

		var lineXStart = direction==LeftToRight ? 0.0 : lineWidth;
		var xPosBase : Float = lineXStart;
		var yPosBase : Float = lineNumber*lineHeight;

		for (word in words) {
			var renderedWord = OpenflHarbuzzCFFI.layoutText(face, createBuffer(word));
			var wordWidth = layouWidth(renderedWord);

			if (word == "\n" || isEndOfLine(xPosBase, wordWidth, lineWidth)) {
				// Newline
				lineNumber++;
				xPosBase = lineXStart;
				yPosBase = lineNumber*lineHeight;
				if(StringTools.isSpace(word,0)) continue;
			}

			var xPos = xPosBase;
			if (direction==RightToLeft)	xPos-=wordWidth;
			var yPos = yPosBase;

			for (posInfo in renderedWord) {

				var g = glyphs[posInfo.codepoint];
				if(g==null) {
					trace("WOW! I'm missing a glyph for the following word: "+word);
					trace("This should not be happening! Your text will be renderer badly :(");
					trace("CODEPINT "+posInfo.codepoint);
					trace(posInfo);
					continue;
				}
				var dstX = Std.int(xPos + posInfo.offset.x + g.bitmapLeft);
				var dstY = Std.int(yPos + posInfo.offset.y - g.bitmapTop);
				var avanceX = posInfo.advance.x / (100/64); // 100/64 = 1.5625 = Magic!
				var avanceY = posInfo.advance.y / (100/64);

				if (xPos+avanceX>=lineWidth && direction==LeftToRight) {
					// Newline
					lineNumber++;
					xPos = 0;
					yPos = lineNumber*lineHeight;
					dstX = Std.int(xPos + posInfo.offset.x + g.bitmapLeft);
					dstY = Std.int(yPos + posInfo.offset.y - g.bitmapTop);
				}

				renderList.push({ codepoint : g.codepoint, x : dstX, y : dstY });

				xPos += avanceX;
				yPos += avanceY;
			}

			if (direction==LeftToRight) {
				xPosBase += wordWidth;
			} else {
				xPosBase -= wordWidth;
			}

		}

		return renderer.render(lineWidth, (lineNumber)*lineHeight, renderList, ((color>>16)&0xff)/255.0, ((color>>8)&0xff)/255.0, (color&0xff)/255.0);

	}

}
