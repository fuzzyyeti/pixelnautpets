extends KinematicBody2D
class_name Pixelnaut

const ACCELERATION := 10
const DECELERATION := 2
const CURRENT_SPEED := 100
const CURRENT_DELTA := 3 
const CURRENT_DIRECTION := Vector2.UP
const MAX_SPEED := 400

enum {
	POD,
	IDLE,
	CHASE,
	WANDER
}

var motion : NPCMotion
var click : JavaScriptObject
var mint_number: int
var join_pod: FuncRef

var speed_offset : float = 0
var current_rect : Rect2


export var state = WANDER

var is_podding = false
var is_playable = false
var velocity = Vector2.ZERO

func _process_current():
	if current_rect.has_point(self.position):
		speed_offset = CURRENT_SPEED
	else:
		if is_playable:
			speed_offset = 0
#		else:
#			speed_offset = move_toward(speed_offset, 0, CURRENT_DELTA)
		
func _add_asset(sprite_type : String, sprite_name : String) -> void:
	if(sprite_name == 'none'): return
	
	var sprite : Sprite = get_node(sprite_type)
	
	var sprite_path_format = 'res://Pixelnauts/assets/{stype}/{stype}-{sname}.png'
	var sprite_path = sprite_path_format.format({
		'stype': sprite_type.to_lower(),
		'sname': sprite_name
	})
	sprite.texture = load(sprite_path)


func build_sprite(attributes: Dictionary):
	_add_asset('Body', attributes['body'])
	_add_asset('Mouth', attributes['mouth'])
	_add_asset('Eyes', attributes['eyes'])
	_add_asset('Hat', attributes['hats'])
	
	$MintId.set_text(str(mint_number))
	$MintId.hide()

	name = 'pixelnaut_{id}'.format({'id': mint_number})


func _physics_process(delta):
	if is_playable == false:
		if state == POD:
			var proximal_npcs = pod_state()
			if(len(proximal_npcs) > 0):
				proximal_npcs.append(self)
				join_pod.call_func(proximal_npcs)
		motion.wander_state()
		velocity = (motion.speed * delta * motion.direction) +\
		 (speed_offset * delta * CURRENT_DIRECTION)	
		flip_sprite_by_direction()
	else:
		move_state(delta)
	_process_current()	
	var collision = move_and_collide(velocity)
	if collision:
		velocity = velocity.bounce(collision.normal) 
		if(!is_playable):
			motion.direction = velocity.normalized()  
		 

		
func set_current_rect(current_rect):
	self.current_rect = current_rect	

func set_random_spawn_point(MAX_X, MAX_Y):
	position.x = rand_range(75, MAX_X - 20)
	position.y = rand_range(24, MAX_Y - 20)


func accelerate_towards_point(point, delta):
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction,  ACCELERATION * delta / 2) +\
		 (speed_offset * delta * CURRENT_DIRECTION)	
	flip_sprite_by_direction()

func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	velocity = velocity.move_toward(input_vector * 2, (DECELERATION if input_vector == Vector2.ZERO  else ACCELERATION) * delta) +\
		(speed_offset * delta * CURRENT_DIRECTION)	
	velocity = velocity.clamped(MAX_SPEED * delta)
	flip_sprite_by_direction()

func pod_state():
	var hits = []	
	var aquarium = get_parent()
	var pod_size = len(aquarium.podding_pixelnauts)
	if (pod_size == 0 || is_podding):
		for pixelnaut in aquarium.get_children():
			if pixelnaut.name.begins_with('pixelnaut_'):
				if(is_podding and pixelnaut.is_podding == true): continue
				
				var distance = position.distance_to(pixelnaut.position)
				
				if distance > 20 and distance < 30:
					hits.append(pixelnaut)		
	return hits


func set_motion(npc_motion: NPCMotion):
	if(is_playable):
		return
	assert(is_playable == false, 'Playable bodies cannot have motion fixed.')
	self.motion = npc_motion
	

func set_click(click : JavaScriptObject):
	self.click = click
	

func set_join_pod_func(join_pod_func_ref: FuncRef):
	self.join_pod = join_pod_func_ref
	
	
func flip_sprite_by_direction():
	for attribute in get_children():
		if attribute.get_class() == 'Sprite':
			attribute.flip_h = velocity.x < 0
			if (attribute.flip_h and attribute.position.x > 0) \
				or (!attribute.flip_h and attribute.position.x < 0):
				attribute.position.x = -attribute.position.x

func _on_Pixelnaut_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if click and event.button_index == BUTTON_LEFT and event.pressed:
			click.click(mint_number)
			

func _on_Pixelnaut_mouse_entered():
	pass # $MintId.show()


func _on_Pixelnaut_mouse_exited():
	$MintId.hide()
