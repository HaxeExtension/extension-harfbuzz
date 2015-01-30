#include "openfl-harfbuzz.h"

#include <algorithm>
#include <vector>
#include <math.h>

#include <hx/CFFI.h>

#include <ft2build.h>
#include FT_FREETYPE_H
#include FT_GLYPH_H
#include FT_OUTLINE_H
#include FT_BITMAP_H

#include <hb.h>
#include <hb-ft.h>

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

	value loadGlyphsForBuffer(FT_Face *face, hb_buffer_t *buffer) {
		
		hb_font_t *hbFont = hb_ft_font_create(*face, NULL);
		hb_shape(hbFont, buffer, NULL, 0);
		
		unsigned int glyph_count;
		hb_glyph_info_t *glyph_info = hb_buffer_get_glyph_infos(buffer, &glyph_count);
		printf("Glyphs: %u\n", glyph_count);

		int maxGlyphWidth = -1;
		int maxGlyphHeight = -1;
		std::vector<int> glyphsCodepoints;
		for (int i = 0; i<glyph_count; i++) {
			
			if (std::find(glyphsCodepoints.begin(), glyphsCodepoints.end(), glyph_info[i].codepoint) != glyphsCodepoints.end()) {	// (Contains)
				printf("Glyph code=%i was already loaded.\n", glyph_info[i].codepoint);
				continue;
			}

			if (FT_Load_Glyph(*face, glyph_info[i].codepoint, FT_LOAD_RENDER)!=FT_Err_Ok) {
				printf("FT_Load_Glyph error, codepoint=%i\n", glyph_info[i].codepoint);
			}

			glyphsCodepoints.push_back(glyph_info[i].codepoint);

			maxGlyphWidth = std::max(maxGlyphWidth, (*face)->glyph->bitmap.width);
			maxGlyphHeight = std::max(maxGlyphHeight, (*face)->glyph->bitmap.rows);
		}

		maxGlyphWidth++;	// Margin
		maxGlyphHeight++;	// Margin

		int rowCols = ceil(sqrt(glyph_count));
		int minBmpWidth = rowCols*maxGlyphWidth;
		int minBmpHeight = rowCols*maxGlyphHeight;

		int bmpWidth = 1;
		while (bmpWidth<minBmpWidth) bmpWidth*=2;
		int bmpHeight = 1;
		while (bmpHeight<minBmpHeight) bmpHeight*=2;
		printf("bmpW=%i, bmpH=%i\n", bmpWidth, bmpHeight);

		//ByteArray *glyphAtlas = new ByteArray(bmpWidth*bmpHeight);
		value glyphAtlas = alloc_array(bmpWidth*bmpHeight);

		int xPos = 0;
		int yPos = 0;
		//for (auto &g: glyphs) {
		for (int i = 0; i<glyph_count; i++) {
			if (FT_Load_Glyph(*face, glyph_info[i].codepoint, FT_LOAD_RENDER)!=FT_Err_Ok) {
				printf("FT_Load_Glyph error, codepoint=%i\n", glyph_info[i].codepoint);
			}
			int codepoint = glyph_info[i].codepoint;
			//FT_Bitmap *glyphBmp = g.second;
			FT_Bitmap glyphBmp;
			FT_Bitmap_New(&glyphBmp);
			FT_Bitmap_Convert(library, &((*face)->glyph->bitmap), &glyphBmp, 1);

			//int glyphAtlasBase = xPos%bmpWidth + yPos/bmpWidth;
			for (int yGlyph=0; yGlyph<glyphBmp.rows; ++yGlyph) {
				for (int xGlyph=0; xGlyph<glyphBmp.width; ++xGlyph) {
					unsigned char srcPix = glyphBmp.buffer[yGlyph*glyphBmp.width + xGlyph];
					//int dstPos = (xPos+xGlyph)%bmpWidth + (yPos+yGlyph*glyphBmp.width)/bmpWidth;
					int dstPos = (yPos+yGlyph)*bmpWidth + (xPos+xGlyph);
					printf("%i, glyph=%i\n", dstPos, codepoint);
					val_array_set_i(glyphAtlas, dstPos, alloc_int(srcPix<<16|srcPix<<8|srcPix));
				}
			}
			printf("%i %i, glyph=%i, width=%i\n", xPos, yPos, codepoint, glyphBmp.width);
			xPos += maxGlyphWidth;
			if (xPos+maxGlyphHeight>bmpWidth) {
				xPos = 0;
				yPos += maxGlyphHeight;
			}
			FT_Bitmap_Done(library, &glyphBmp);
		}

		return glyphAtlas;

	}
	
}
