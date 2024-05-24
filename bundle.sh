#! /usr/bin/bash
path=$(dirname $0)

includedFiles="
    BigYeet.toc
    *.lua
    sounds
    LICENSE
"
tempPath="${path}/bundled"
mkdir $tempPath
cp -rf $includedFiles $tempPath
zip -rm "${path}/BigYeet.zip" "$tempPath"
