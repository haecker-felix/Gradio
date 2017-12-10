find . -type f -iname "*.po" -exec bash -c 'msgmerge --update "{}" gradio.pot' \;
