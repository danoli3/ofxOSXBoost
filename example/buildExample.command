#!/bin/sh

here="`dirname \"$0\"`"
echo "cd-ing to $here"
cd "$here" || exit 1

../../../apps/projectGenerator/commandLine/bin/projectGenerator -v -p"osx" -o"../../../../" ../../../../addons/ofxOSXBoost/example/

echo "Project Built"