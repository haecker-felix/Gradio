#!/bin/bash

for i in 16 22 24 32 48 256 512
do
    inkscape -z -e hicolor/$i\x$i/apps/de.haeckerfelix.gradio.png -w $i -h $i de.haeckerfelix.gradio.svg
    inkscape -z -e hicolor/$i\x$i/apps/gradio.png -w $i -h $i de.haeckerfelix.gradio.svg
done

