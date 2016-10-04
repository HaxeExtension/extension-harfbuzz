package extension.harfbuzz;

import haxe.Utf8;

class UnicodeBlock {
	
	var min : Int;
	var max : Int;
	public var script(default, null) : TextScript;

	public function new(min : Int, max : Int, script : TextScript) {
		this.min = min;
		this.max = max;
		this.script = script;
	}

	public function test(utfCharCode : Int) : Bool {
		return min<=utfCharCode && max>=utfCharCode;
	}

}

class ScriptIdentificator {

	static var blocks = [
		// Latin
		new UnicodeBlock(0x0000, 0x007F, ScriptLatin),
		new UnicodeBlock(0x0100, 0x017F, ScriptLatin),
		new UnicodeBlock(0x0180, 0x024F, ScriptLatin),

		// Hebrew
		new UnicodeBlock(0x0590, 0x05FF, ScriptHebrew),

		// Arabic
		new UnicodeBlock(0x0600, 0x06ff, ScriptArabic),
		new UnicodeBlock(0x0750, 0x077F, ScriptArabic),
		new UnicodeBlock(0x08A0, 0x08FF, ScriptArabic),
		new UnicodeBlock(0xFB50, 0xFDFF, ScriptArabic),
		new UnicodeBlock(0xFE70, 0xFEFF, ScriptArabic),
		new UnicodeBlock(0x10E60, 0x10E7F, ScriptArabic),
		new UnicodeBlock(0x1EE00, 0x1EEFF, ScriptArabic)
	];
	
	static function getCharCodeScript(utfCharCode : Int) : TextScript {
		for (block in blocks) {
			if (block.test(utfCharCode))	return block.script;
		}
		return ScriptCommon;
	}

	public static function identify(text : String, preferredScript:String = null) : TextScript {
		
		var scriptsCount = new Map<String, Int>();
		var utfLen = Utf8.length(text);
		
		scriptsCount[TextScript.ScriptCommon] = 0;
		if(preferredScript!=null) scriptsCount[preferredScript] = 1;
		
		for (i in 0...utfLen) {
			var char = new Utf8();
			var charCode = Utf8.charCodeAt(text, i);
			char.addChar(charCode);
			var script = getCharCodeScript(charCode);
			scriptsCount[script] = scriptsCount[script] == null ? 1 : scriptsCount[script]+1;
		}

		var mostCommonScript = TextScript.ScriptCommon;
		for (script in scriptsCount.keys()) {
			if (scriptsCount[mostCommonScript]<scriptsCount[script]) {
				mostCommonScript = script;
			}
		}

		return mostCommonScript;

	}

}
