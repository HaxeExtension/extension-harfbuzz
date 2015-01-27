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
	bool ret = loadFontFaceFromFile(val_string(filePath), val_int(faceIndex));
	return alloc_bool(ret);
}
DEFINE_PRIM(openfl_harfbuzz_loadFontFaceFromFile, 2);

static value openfl_harfbuzz_setFontSize(value size) {
	setFontSize(val_int(size));
	return alloc_null();
}
DEFINE_PRIM(openfl_harfbuzz_setFontSize, 1);

void openfl_harfbuzz_destroyBuffer(value handle) {
	printf("destructor\n");
	hb_buffer_t *buffer = (hb_buffer_t *)(intptr_t)val_float(handle);
	destroyBuffer(buffer);
}

static value openfl_harfbuzz_createBuffer(value direction, value script, value language) {
	hb_buffer_t *buffer = createBuffer(val_int(direction), val_string(script), val_string(language));
	value v = alloc_float((intptr_t)buffer);
	val_gc(v, openfl_harfbuzz_destroyBuffer);
	return v;
}
DEFINE_PRIM(openfl_harfbuzz_createBuffer, 3);

extern "C" void openfl_harfbuzz_main () {
	
	val_int(0); // Fix Neko init
	
}
DEFINE_ENTRY_POINT (openfl_harfbuzz_main);

extern "C" int openfl_harfbuzz_register_prims () { return 0; }
