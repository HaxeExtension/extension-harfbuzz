#ifndef OPENFL_HARFBUZZ_H
#define OPENFL_HARFBUZZ_H

#include <hb.h>

namespace openfl_harfbuzz {
	
	void init();
	bool loadFontFaceFromFile(const char *filePath, int faceIndex);
	void setFontSize(int size);
	hb_buffer_t *createBuffer(hb_tag_t direction, const char *script, const char *language);
	void destroyBuffer(hb_buffer_t *buffer);
	
}

#endif
