#ifndef STATIC_LINK
#define IMPLEMENT_API
#endif

#if defined(HX_WINDOWS) || defined(HX_MACOS) || defined(HX_LINUX)
#define NEKO_COMPATIBLE
#endif


#include <hx/CFFI.h>
#include "openfl-harfbuzz.h"

using namespace openfl_harfbuzz;

static value openfl_harfbuzz_init() {
	init();
	return alloc_null();
}
DEFINE_PRIM(openfl_harfbuzz_init, 0);

static value openfl_harfbuzz_loadFontFaceFromFile(value filePath, value faceIndex) {
	FT_Face *ret = loadFontFaceFromFile(val_string(filePath), val_int(faceIndex));
	value v = alloc_float ((intptr_t)ret);
	// val_gc(v, ???);
	return v;
}
DEFINE_PRIM(openfl_harfbuzz_loadFontFaceFromFile, 2);

static value openfl_harfbuzz_setFontSize(value faceHandle, value size) {
	FT_Face *face = (FT_Face*)(intptr_t)val_float(faceHandle);
	setFontSize(face, val_int(size));
	return alloc_null();
}
DEFINE_PRIM(openfl_harfbuzz_setFontSize, 2);

void openfl_harfbuzz_destroyBuffer(value handle) {
	hb_buffer_t *buffer = (hb_buffer_t *)(intptr_t)val_float(handle);
	destroyBuffer(buffer);
}

static value openfl_harfbuzz_createBuffer(value direction, value script, value language, value text) {
	hb_buffer_t *buffer = createBuffer(val_int(direction), val_string(script), val_string(language), val_string(text));
	value v = alloc_float((intptr_t)buffer);
	val_gc(v, openfl_harfbuzz_destroyBuffer);
	return v;
}
DEFINE_PRIM(openfl_harfbuzz_createBuffer, 4);

static value openfl_harfbuzz_loadGlyphsForBuffer(value faceHandle, value bufferHandle) {
	FT_Face *face = (FT_Face*)(intptr_t)val_float(faceHandle);
	hb_buffer_t *buffer = (hb_buffer_t *)(intptr_t)val_float(bufferHandle);
	loadGlyphsForBuffer(face, buffer);
	return alloc_null();
}
DEFINE_PRIM(openfl_harfbuzz_loadGlyphsForBuffer, 2);

extern "C" void openfl_harfbuzz_main () {
	
	val_int(0); // Fix Neko init
	
}
DEFINE_ENTRY_POINT (openfl_harfbuzz_main);

extern "C" int openfl_harfbuzz_register_prims () { return 0; }
