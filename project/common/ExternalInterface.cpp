#ifndef STATIC_LINK
#define IMPLEMENT_API
#endif

#if defined(HX_WINDOWS) || defined(HX_MACOS) || defined(HX_LINUX)
#define NEKO_COMPATIBLE
#endif

#include "openfl-harfbuzz.h"
#include <ft2build.h>
#include <hx/CFFI.h>
#include FT_FREETYPE_H

using namespace openfl_harfbuzz;

namespace openfl_harfbuzz {

	#ifdef BLACKBERRY
	void log(const char *msg) {
		/*
		FILE *logFile = fopen("logs/log.txt", "a");
		fprintf(logFile, "%s\n", msg);
		fclose(logFile);
		*/
	}
	#else
	void log(const char *msg) {
		printf("%s", msg);
	}
	#endif

}

static value openfl_harfbuzz_init() {
	init();
	/*
	FILE *logFile = fopen("logs/log.txt", "w");
	fclose(logFile);
	*/
	return alloc_null();
}
DEFINE_PRIM(openfl_harfbuzz_init, 0);

void openfl_harfbuzz_destroyFace(value handle) {
	FT_Face *face = (FT_Face *)(intptr_t)val_float(handle);
	destroyFace(face);
}

static value openfl_harfbuzz_loadFontFaceFromFile(value filePath, value faceIndex) {
	FT_Face *ret = loadFontFaceFromFile(val_string(filePath), val_int(faceIndex));
	
	value v = alloc_float((intptr_t)ret);
	val_gc(v, openfl_harfbuzz_destroyFace);

	return v;
}
DEFINE_PRIM(openfl_harfbuzz_loadFontFaceFromFile, 2);

static value openfl_harfbuzz_loadFontFaceFromMemory(value bytes, value faceIndex) {

	buffer bBuffer = val_to_buffer(bytes);
	FT_Face *ret = loadFontFaceFromMemory(
		(const unsigned char *)buffer_data(bBuffer),
		buffer_size(bBuffer),
		val_int(faceIndex)
	);

	value v = alloc_float((intptr_t)ret);
	val_gc(v, openfl_harfbuzz_destroyFace);

	return v;

}
DEFINE_PRIM(openfl_harfbuzz_loadFontFaceFromMemory, 2);

static value openfl_harfbuzz_setFontSize(value faceHandle, value size) {
	FT_Face *face = (FT_Face*)(intptr_t)val_float(faceHandle);
	setFontSize(face, val_int(size));
	return alloc_null();
}
DEFINE_PRIM(openfl_harfbuzz_setFontSize, 2);

/*
void openfl_harfbuzz_destroyBuffer(value handle) {
	hb_buffer_t *buffer = (hb_buffer_t *)(intptr_t)val_float(handle);

	char msg[64];
	snprintf(msg, 64, "-> openfl_harfbuzz_destroyBuffer: %ld\n", (intptr_t)buffer);
	log(msg);

	destroyBuffer(buffer);
}
*/

static value openfl_harfbuzz_createBuffer(value direction, value script, value language, value text) {
	hb_buffer_t *buffer = createBuffer(val_int(direction), val_string(script), val_string(language), val_string(text));
	value v = alloc_float((intptr_t)buffer);
	return v;
}
DEFINE_PRIM(openfl_harfbuzz_createBuffer, 4);

static value openfl_harfbuzz_createGlyphAtlas(value faceHandle, value bufferHandle) {
	FT_Face *face = (FT_Face*)(intptr_t)val_float(faceHandle);
	hb_buffer_t *buffer = (hb_buffer_t *)(intptr_t)val_float(bufferHandle);
	return createGlyphAtlas(face, buffer);
}
DEFINE_PRIM(openfl_harfbuzz_createGlyphAtlas, 2);

static value openfl_harfbuzz_layoutText(value faceHandle, value bufferHandle) {
	FT_Face *face = (FT_Face*)(intptr_t)val_float(faceHandle);
	hb_buffer_t *buffer = (hb_buffer_t *)(intptr_t)val_float(bufferHandle);
	value ret = layoutText(face, buffer);
	return ret;
}
DEFINE_PRIM(openfl_harfbuzz_layoutText, 2);

static value openfl_harfbuzz_getFaceMetrics(value faceHandle) {
	FT_Face *face = (FT_Face*)(intptr_t)val_float(faceHandle);
	return getFaceMetrics(face);
}
DEFINE_PRIM(openfl_harfbuzz_getFaceMetrics, 1);

extern "C" void openfl_harfbuzz_main () {

	val_int(0); // Fix Neko init

}
DEFINE_ENTRY_POINT (openfl_harfbuzz_main);

extern "C" int openfl_harfbuzz_register_prims () { return 0; }
