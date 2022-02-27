extends TextureRect

func ready():
	connect("mouse_entered", self, "_on_TextureRect_mouse_entered")
	connect("mouse_exited", self, "_on_TextureRect_mouse_exited")
