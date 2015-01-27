#include "Utils.h"

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

	FT_Library library;

	void init() {
		FT_Error error = FT_Init_FreeType(&library);
		if (error!=FT_Err_Ok) {
			throw "Error initializing FreeType";
		}
		printf("Harbuzz init: %lu\n", (unsigned long)&library);
	}

}
