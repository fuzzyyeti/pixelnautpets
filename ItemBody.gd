extends KinematicBody2D

signal position_update

# Called when the node enters the scene tree for the first time.
var can_grab = false
var grabbed_offset = Vector2()

var item_type = ""

func _process(delta):
	if Input.is_mouse_button_pressed(BUTTON_LEFT) and can_grab:
		#position = get_global_mouse_position() + grabbed_offset
		move_and_slide(((get_global_mouse_position() + grabbed_offset) - position).normalized() * 400)
		if get_slide_collision(0):
			if $Timer.is_stopped():
				$Timer.start(2)
func _on_ItemBody_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		can_grab = event.pressed
		grabbed_offset = position - get_global_mouse_position()
		if not event.pressed:
			print(position)
			emit_signal("position_update", position, item_type)
				


func _on_Timer_timeout():
	print("collision emit")
	$Timer.stop()
	emit_signal("position_update", position, item_type)
	 # Replace with function body.
