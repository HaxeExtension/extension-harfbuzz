#!/bin/bash
dir=`dirname "$0"`
cd "$dir"

lime rebuild . ios && \
lime rebuild . mac && \
lime rebuild . android && \
# lime rebuild . blackberry && \
rm -f extension-harfbuzz.zip && \
zip -r extension-harfbuzz.zip extension haxelib.json include.xml project ndll dependencies -x "project/obj/*"
