extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var icon = load('res://icon.png')
var icon2 = load('res://Pixelnauts/assets/accessory/accessory-atlas_ship.png')

# Called when the node enters the scene tree for the first time.
func _ready():
	for x in range(5):
		print(x)
		var c = Control.new()
		$ItemShelf.add_child(c)
#		var s = Sprite.new()
#		s.texture = icon
#		$ItemShelf.add_child(s)
#		s = Sprite.new()
#		s.texture = icon2
#		s.hframes = 10
#		$ItemShelf.add_child(s)



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Control_gui_input(event):
	print(event) # Replace with function body.
