#!/bin/bash

[[ $(hostname) == "super" ]] && download="/media/external1/downloads"

if [[ -n ${download} ]]; then
	mv ${download}/*.png ${download}/*.jpg ${download}/*.jpeg ${download}/*.gif ${download}/images 2>/dev/null
	mv ${download}/*.pdf ${download}/pdf 2>/dev/null
	mv ${download}/*.xlsx ${download}/excel 2>/dev/null
	mv ${download}/*.7z ${download}/*.zip ${download}/*.rar ${download}/*.tar ${download}/*.tar.gz ${download}/compressed 2>/dev/null
fi
