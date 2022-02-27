extends Node2D
const Pixelnaut = preload("res://Pixelnauts/Pixelnaut.tscn")
const NPCMotion = preload("res://Pixelnauts/NPCMotion.gd")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$HTTPRequest.connect("request_completed", self, "_on_request_completed")
	var query = JSON.print({"mint":"hME4W9UibULcSzvd3ux4zvVKioWXhW5LErWS6Sd3Tfb"})
	# Add 'Content-Type' header:
	var headers = ["Content-Type: application/json"]
	$HTTPRequest.request("http://localhost:5000/tank/load",headers, false, HTTPClient.METHOD_GET, query)

	

func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	
	print(json.result.orcanaut.attributes)
	var a = json.result.orcanaut.attributes
	
	var pixelnaut: KinematicBody2D = Pixelnaut.instance()

	var npc_motion = NPCMotion.new(rand_range(20,75), Vector2.RIGHT)
	pixelnaut.set_motion(npc_motion)
	pixelnaut.build_sprite(a)
	pixelnaut.position = Vector2(200,200)
	add_child(pixelnaut)
