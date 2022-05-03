#!/bin/bash

find . -name .DS_Store -type f -delete

mkdocs build -d ../scriptsharks.github.io
cp gh-readme.md ../scriptsharks.github.io/README.md
