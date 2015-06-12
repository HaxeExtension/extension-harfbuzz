#!/bin/bash
dir=`dirname "$0"`
cd "$dir"
haxelib remove extension-harfbuzz
haxelib local extension-harfbuzz.zip
