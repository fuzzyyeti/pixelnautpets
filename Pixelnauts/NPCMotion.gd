extends Object
class_name NPCMotion

const DART_PROB : float = 0.05
var speed : float
var base_speed : float
var direction : Vector2
var speed_variation_step := PI/200
var speed_variation : float = 0
var dart_prob_divider : int = 1


func _init(npc_speed : float, npc_direction : Vector2) -> void:
	self.base_speed = npc_speed
	self.speed = npc_speed
	self.direction = npc_direction

func wander_state() -> void:
	var osc = _oscillate_speed()
	speed = base_speed * osc
	if rand_range(0,10) > 10 - DART_PROB / dart_prob_divider:
		dart_updates()

func dart_updates() -> void:
	var x = -direction.x
	var y = 0;
	var straighishProb = rand_range(0,1)
	if(straighishProb > 0.7):
		y = rand_range(-1,1)
	else:
		y = rand_range(-0.1,0.1)
	base_speed = rand_range(60, 120)
	speed = base_speed
	var osc_prob = rand_range(0,1)
	if(osc_prob > 0.5):
		speed_variation_step = rand_range(PI/10, PI/300)
	else:
		speed_variation_step = 0
	direction = Vector2(x, y).normalized()
	
#Private 	
func _oscillate_speed() -> float:
	speed_variation += speed_variation_step
	return sin(speed_variation) * .25 + .75
