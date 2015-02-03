#ifndef OPENFL_HARFBUZZ_H
#define OPENFL_HARFBUZZ_H

#include <hx/CFFI.h>

#include <hb.h>
#include <ft2build.h>
#include FT_FREETYPE_H

namespace openfl_harfbuzz {
	
	void init();
	FT_Face *loadFontFaceFromFile(const char *filePath, int faceIndex);
	void setFontSize(FT_Face *face, int size);
	hb_buffer_t *createBuffer(hb_tag_t direction, const char *script, const char *language, const char *text);
	void destroyBuffer(hb_buffer_t *buffer);
	value createGlyphAtlas(FT_Face *face, hb_buffer_t *buffer);
	value layoutText(FT_Face *face, hb_buffer_t *buffer);
	
}

#endif
