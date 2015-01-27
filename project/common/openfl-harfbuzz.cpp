#include "openfl-harfbuzz.h"

#include <ft2build.h>
#include FT_FREETYPE_H
/*
#include FT_BITMAP_H
#include FT_SFNT_NAMES_H
#include FT_TRUETYPE_IDS_H
#include FT_GLYPH_H
#include FT_OUTLINE_H
*/

namespace openfl_harfbuzz {

	FT_Library	library;
	FT_Face		face;

	void init() {
		FT_Error error = FT_Init_FreeType(&library);
		if (error!=FT_Err_Ok) {
			throw "Error initializing FreeType";
		}
		printf("Harbuzz init: %lu\n", (unsigned long)&library);
	}

	/**
	* @return true if no error ocurred, false otherwhise.
	*/
	bool loadFontFaceFromFile(const char *filePath, int faceIndex) {
		FT_Error error = FT_New_Face(library, filePath, faceIndex, &face);
		return error==FT_Err_Ok;
	}

	void setFontSize(int size) {
		int hdpi = 72;
		int vdpi = 72;
		int hres = 100;
		FT_Matrix matrix = {
			(int)((1.0/hres) * 0x10000L),
			(int)((0.0) * 0x10000L),
			(int)((0.0) * 0x10000L),
			(int)((1.0) * 0x10000L)
		};
		FT_Set_Char_Size(face, 0, (int)(size*64), (int)(hdpi * hres), vdpi);
		FT_Set_Transform(face, &matrix, NULL);
	}

}
