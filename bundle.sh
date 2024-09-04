#! /usr/bin/bash
path=$(dirname $0)

includedFiles="
    *.lua
    sounds
    LICENSE
"
tempPath="${path}/bundled"
mkdir $tempPath
cp -rf $includedFiles $tempPath
cp -rf "BigYeet.toc" "${tempPath}/bundled.toc"
zip -rm "${path}/BigYeet.zip" "$tempPath"
