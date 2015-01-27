#ifndef OPENFL_HARFBUZZ_H
#define OPENFL_HARFBUZZ_H

namespace openfl_harfbuzz {
	
	void init();
	bool loadFontFaceFromFile(const char *filePath, int faceIndex);
	void setFontSize(int size);
	
}

#endif
