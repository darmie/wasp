#!/bin/sh
rm -f Wasp.zip
zip -r Wasp.zip src *.hxml *.json *.md
haxelib submit Wasp.zip $HAXELIB_PWD --always