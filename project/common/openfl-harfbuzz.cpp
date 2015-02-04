#include "openfl-harfbuzz.h"

#include <algorithm>
#include <set>
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

	static inline float	to_float (hb_position_t v) {
	   return scalbnf (v, -12);
	}

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

	void destroyFace(FT_Face *face) {
		FT_Done_Face(*face);
		//printf("free face\n");
	}

	// TODO: Improve this function.
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
		FT_Set_Char_Size(*face, 0, (int)(size*64), (int)(hdpi*hres), vdpi);
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
		//printf("free buffer\n");
	}

	/**
	 * createGlyphAtlas
	 */
	value createGlyphAtlas(FT_Face *face, hb_buffer_t *buffer) {

		hb_font_t *hbFont = hb_ft_font_create(*face, NULL);
		hb_shape(hbFont, buffer, NULL, 0);

		unsigned int glyph_count;
		hb_glyph_info_t *glyph_info = hb_buffer_get_glyph_infos(buffer, &glyph_count);

		// First pass, get glyphs sizes
		int maxGlyphWidth = -1;
		int maxGlyphHeight = -1;
		std::set<int> glyphsCodepoints;
		int uniqueGlyphs = 0;
		for (int i = 0; i<glyph_count; i++) {

			int codepoint = glyph_info[i].codepoint;

			if (glyphsCodepoints.find(codepoint)!=glyphsCodepoints.end()) {
				printf("Glyph code=%i was already loaded.\n", codepoint);
				continue;
			}

			if (FT_Load_Glyph(*face, codepoint, FT_LOAD_RENDER)!=FT_Err_Ok) {
				printf("FT_Load_Glyph error, codepoint=%i\n", codepoint);
			}

			glyphsCodepoints.insert(codepoint);
			++uniqueGlyphs;

			maxGlyphWidth = std::max(maxGlyphWidth, (*face)->glyph->bitmap.width);
			maxGlyphHeight = std::max(maxGlyphHeight, (*face)->glyph->bitmap.rows);

		}

		maxGlyphWidth++;	// Margin
		maxGlyphHeight++;	// Margin

		int rowCols = ceil(sqrt(uniqueGlyphs));
		int minBmpWidth = rowCols*maxGlyphWidth;
		int minBmpHeight = rowCols*maxGlyphHeight;

		int bmpWidth = 1;
		while (bmpWidth<minBmpWidth) bmpWidth*=2;
		int bmpHeight = 1;
		while (bmpHeight<minBmpHeight) bmpHeight*=2;

		// hxcffi vars
		value obj = alloc_empty_object();
		value glyphAtlas = alloc_array(bmpWidth*bmpHeight);
		value glyphRects = alloc_array(uniqueGlyphs);

		// Second pass, render glyphs to atlas
		int xPos = 0;
		int yPos = 0;
		int glyphIndex = 0;

		for (auto codepoint : glyphsCodepoints) {

			if (FT_Load_Glyph(*face, codepoint, FT_LOAD_RENDER)!=FT_Err_Ok) {
				printf("FT_Load_Glyph error, codepoint=%i\n", codepoint);
			}

			FT_Bitmap glyphBmp;
			FT_GlyphSlot ftGlyphRect = (*face)->glyph;
			FT_Bitmap_New(&glyphBmp);
			//FT_Bitmap_Convert(library, &((*face)->glyph->bitmap), &glyphBmp, 1);
			FT_Bitmap_Convert(library, &(ftGlyphRect->bitmap), &glyphBmp, 1);

			for (int yGlyph=0; yGlyph<glyphBmp.rows; ++yGlyph) {
				for (int xGlyph=0; xGlyph<glyphBmp.width; ++xGlyph) {

					unsigned char srcPix = glyphBmp.buffer[yGlyph*glyphBmp.width + xGlyph];
					int dstPos = (yPos+yGlyph)*bmpWidth + (xPos+xGlyph);

					// hxcffi

					val_array_set_i(glyphAtlas, dstPos, alloc_int((srcPix<<24)|0xffffff));

				}
			}

			// hxcffi
			value glyphRect = alloc_empty_object();
			alloc_field(glyphRect, val_id("codepoint"), alloc_int(codepoint));
			alloc_field(glyphRect, val_id("x"), alloc_int(xPos));
			alloc_field(glyphRect, val_id("y"), alloc_int(yPos));
			alloc_field(glyphRect, val_id("width"), alloc_int(glyphBmp.width));
			alloc_field(glyphRect, val_id("height"), alloc_int(glyphBmp.rows));
			alloc_field(glyphRect, val_id("bitmapLeft"), alloc_int(ftGlyphRect->bitmap_left));
			alloc_field(glyphRect, val_id("bitmapTop"), alloc_int(ftGlyphRect->bitmap_top));
			alloc_field(glyphRect, val_id("advanceX"), alloc_float(to_float(ftGlyphRect->metrics.horiAdvance)));
			alloc_field(glyphRect, val_id("bearingX"), alloc_float(to_float(ftGlyphRect->metrics.horiBearingX)));
			alloc_field(glyphRect, val_id("bearingY"), alloc_float(to_float(ftGlyphRect->metrics.horiBearingY)));
			val_array_set_i(glyphRects, glyphIndex, glyphRect);

			FT_Bitmap_Done(library, &glyphBmp);

			xPos += maxGlyphWidth;
			if (xPos+maxGlyphHeight>bmpWidth) {
				xPos = 0;
				yPos += maxGlyphHeight;
			}
			++glyphIndex;

		}

		hb_font_destroy(hbFont);

		// hxcffi
		alloc_field(obj, val_id("bmpData"), glyphAtlas);
		alloc_field(obj, val_id("width"), alloc_int(bmpWidth));
		alloc_field(obj, val_id("height"), alloc_int(bmpHeight));
		alloc_field(obj, val_id("glyphRects"), glyphRects);

		return obj;

	}

	/**
	 * layoutText
	 */
	value layoutText(FT_Face *face, hb_buffer_t *buffer) {

		hb_font_t *hbFont = hb_ft_font_create(*face, NULL);
		hb_shape(hbFont, buffer, NULL, 0);

		unsigned int glyph_count;
		hb_glyph_info_t *glyph_info = hb_buffer_get_glyph_infos(buffer, &glyph_count);
		hb_glyph_position_t *glyph_pos = hb_buffer_get_glyph_positions(buffer, &glyph_count);

		value posInfo = alloc_array(glyph_count);
		int posIndex = 0;

		for (int i = 0; i<glyph_count; ++i) {

			hb_glyph_position_t pos = glyph_pos[i];

			value obj = alloc_empty_object ();
			alloc_field (obj, val_id ("codepoint"), alloc_int(glyph_info[i].codepoint));

			value advance = alloc_empty_object();
			alloc_field(advance, val_id("x"), alloc_float(to_float(pos.x_advance)));
			alloc_field(advance, val_id("y"), alloc_float(to_float(pos.y_advance)));
			alloc_field(obj, val_id("advance"), advance);

			value offset = alloc_empty_object();
			alloc_field(offset, val_id("x"), alloc_float(to_float(pos.x_offset)));
			alloc_field(offset, val_id("y"), alloc_float(to_float(pos.y_offset)));
			alloc_field(obj, val_id("offset"), offset);

			val_array_set_i(posInfo, posIndex++, obj);

		}

		hb_font_destroy (hbFont);

		return posInfo;
	}

}
