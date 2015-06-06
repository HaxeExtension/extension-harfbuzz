#!/bin/bash
dir=`dirname "$0"`
cd "$dir"

lime rebuild . ios && \
lime rebuild . mac && \
lime rebuild . android && \
rm -f openfl-harfbuzz.zip && \
zip -r openfl-harfbuzz.zip extension haxelib.json include.xml project ndll dependencies -x "project/obj/*"
