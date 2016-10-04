package extension.harfbuzz;

class SystemFont {

	static function firstExistingFileIn(arr : Array<String>) : String {
		for (a in arr) {
			if (sys.FileSystem.exists(a)) {
				return a;
			}
		}
		return null;
	}

	static function findAppleFont(arr : Array<String>) : String {
		#if iphone
		var base =  "/System/Library/Fonts/Cache/";
		#else
		var base = "/Library/Fonts/";
		#end
		for (i in 0...arr.length) {
			arr[i] = base + arr[i];
		}
		return firstExistingFileIn(arr);
	}

	public static function getSerif() : String {

		#if android
		return "/system/fonts/DroidSerif-Regular.ttf";

		#elseif webos
		return "/usr/share/fonts/times.ttf";

		#elseif blackberry
		return "/usr/fonts/font_repository/monotype/times.ttf";

		#elseif tizen
		return "/usr/share/fonts/TizenSansRegular.ttf";

		#elseif (iphone || mac)
		return findAppleFont(["Georgia.ttf", "Times.ttf", "Times New Roman.ttf"]);

		#else
		return "/usr/share/fonts/truetype/freefont/FreeSerif.ttf";

		#end

	}

	public static function getSansSerif() : String {

		#if android
		return "/system/fonts/DroidSans.ttf";

		#elseif webos
		return "/usr/share/fonts/Prelude-Medium.ttf";

		#elseif blackberry
		return "/usr/fonts/font_repository/monotype/arial.ttf";

		#elseif tizen
		return "/usr/share/fonts/TizenSansRegular.ttf";

		#elseif (iphone || mac)
		return findAppleFont(["Arial Black.ttf", "Arial.ttf", "Helvetica.ttf"]);

		#else
		return "/usr/share/fonts/truetype/freefont/FreeSans.ttf";

		#end

	}

	public static function getMonospaced() : String {

		#if android
		return "/system/fonts/DroidSansMono.ttf";

		#elseif webos
		return "/usr/share/fonts/cour.ttf";

		#elseif blackberry
		return "/usr/fonts/font_repository/monotype/cour.ttf";

		#elseif tizen
		return "/usr/share/fonts/TizenSansRegular.ttf";

		#elseif (iphone || mac)
		return findAppleFont(["Courier New.ttf", "Courier.ttf"]);

		#else
		return "/usr/share/fonts/truetype/freefont/FreeMono.ttf";

		#end

	}

}
