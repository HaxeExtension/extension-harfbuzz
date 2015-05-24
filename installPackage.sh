#!/bin/bash
dir=`dirname "$0"`
cd "$dir"
haxelib remove openfl-harfbuzz
haxelib local openfl-harfbuzz.zip
