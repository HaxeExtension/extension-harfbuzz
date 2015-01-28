#include "openfl-harfbuzz.h"

#include <hb.h>
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

	void init() {
		FT_Error error = FT_Init_FreeType(&library);
		if (error!=FT_Err_Ok) {
			throw "Error initializing FreeType";
		}
	}

	FT_Face *loadFontFaceFromFile(const char *filePath, int faceIndex) {
		FT_Face *face = new FT_Face;	// TODO: Free this reference
		FT_Error error = FT_New_Face(library, filePath, faceIndex, face);
		return error==FT_Err_Ok ? face : NULL;
	}

	void setFontSize(FT_Face *face, int size) {
		int hdpi = 72;
		int vdpi = 72;
		int hres = 100;
		FT_Matrix matrix = {
			(int)((1.0/hres) * 0x10000L),
			(int)((0.0) * 0x10000L),
			(int)((0.0) * 0x10000L),
			(int)((1.0) * 0x10000L)
		};
		FT_Set_Char_Size(*face, 0, (int)(size*64), (int)(hdpi * hres), vdpi);
		FT_Set_Transform(*face, &matrix, NULL);
	}

	hb_buffer_t *createBuffer(hb_tag_t direction, const char *script, const char *language, const char *text) {
		hb_buffer_t *buffer = hb_buffer_create();
		hb_buffer_set_direction(buffer, (hb_direction_t)direction);
		hb_buffer_set_script(buffer, hb_script_from_string(script, -1));
		hb_buffer_set_language(buffer, hb_language_from_string(language, -1));
		hb_buffer_add_utf8(buffer, text, -1, 0, -1);
		return buffer;
	}

	void destroyBuffer(hb_buffer_t *buffer) {
		hb_buffer_destroy(buffer);
	}

	void loadGlyphsForBuffer(FT_Face *face, hb_buffer_t *buffer) {
		unsigned int glyph_count;
		hb_glyph_info_t *glyph_info = hb_buffer_get_glyph_infos(buffer, &glyph_count);
		printf("Glyphs: %u\n", glyph_count);
	}

}
