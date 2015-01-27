#ifndef STATIC_LINK
#define IMPLEMENT_API
#endif

#if defined(HX_WINDOWS) || defined(HX_MACOS) || defined(HX_LINUX)
#define NEKO_COMPATIBLE
#endif


#include <hx/CFFI.h>
#include "Utils.h"

using namespace openfl_harfbuzz;

static value openfl_harfbuzz_init() {
	init();
}
DEFINE_PRIM(openfl_harfbuzz_init, 0);

extern "C" void openfl_harfbuzz_main () {
	
	val_int(0); // Fix Neko init
	
}
DEFINE_ENTRY_POINT (openfl_harfbuzz_main);

extern "C" int openfl_harfbuzz_register_prims () { return 0; }
