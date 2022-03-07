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
		
func _on_ItemBody_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		can_grab = event.pressed
		grabbed_offset = position - get_global_mouse_position()
		if not event.pressed:
			if $Timer.is_stopped():
				$Timer.start(1)



func _on_Timer_timeout():
	print('got here to timeout')
	emit_signal("position_update", position, item_type)
	$Timer.stop()
