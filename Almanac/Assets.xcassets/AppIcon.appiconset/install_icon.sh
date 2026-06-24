#!/bin/bash
# Decode the base64 icon into a PNG
cd "$(dirname "$0")"
base64 -d icon_1024_b64.txt > icon_1024.png
rm icon_1024_b64.txt
rm "$0"
echo "Icon installed successfully"
