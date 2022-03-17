extends KinematicBody2D

signal position_update

# Called when the node enters the scene tree for the first time.
var can_grab = false
export var test = "test text"
var grabbed_offset = Vector2()
var stopped = true
var item_type = ""

func _ready():
	$Sprite.hframes = 1

func one_frame():
	$Sprite.hframes = 1

func animate(speed, frames):
	$Sprite.hframes = frames
	if speed == 'fast':
		$AnimationPlayer.play("Fast")
	if speed == 'slow':
		$AnimationPlayer.play("Slow")		

func _process(delta):
	if Input.is_mouse_button_pressed(BUTTON_LEFT) and can_grab:
		stopped = false	
		var velocity = (get_global_mouse_position() + grabbed_offset) - position
		move_and_slide(velocity.normalized() * 90)

	else:
		if not stopped:
			emit_signal("position_update", position, item_type)
		stopped = true
		can_grab = false			
func _on_ItemBody_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		can_grab = event.pressed
		grabbed_offset = position - get_global_mouse_position()

			
#	emit_signal("position_update", position, item_type)
	 # Replace with function body.
