void open () {
	assert(true);
}

void main (string[] args) {
	Test.init (ref args);

	GLib.Test.add_func ("/library/open", open);
	Test.run ();
}
