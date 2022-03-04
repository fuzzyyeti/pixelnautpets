extends Node2D
const Pixelnaut = preload("res://Pixelnauts/Pixelnaut.tscn")
const NPCMotion = preload("res://Pixelnauts/NPCMotion.gd")
var _selected = 0
const ItemData = preload("res://ItemData.tres")
const headers = ["Content-Type: application/json"]
const mint = "hME4W9UibULcSzvd3ux4zvVKioWXhW5LErWS6Sd3Tfb"
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$HTTPRequest.connect("request_completed", self, "_on_request_completed")
	var query = JSON.print({"mint":mint})
	# Add 'Content-Type' header:
	$HTTPRequest.request("http://localhost:5000/tank/load",headers, false, HTTPClient.METHOD_GET, query)
	$Panel/PetShop/GridContainer.get_child(0).grab_focus()
	

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


func _on_TextureButton_button_down(button):
	for c in $Panel/PetShop/GridContainer.get_children():
		c.pressed = false
	for c in $Panel/PetShop/GridContainer2.get_children():
		c.pressed = false
	print('button')
	print(button)
	_selected = button

func _on_success_or_fail(result, response_code, headers, body):
	print(body)

func _on_BuyButton_pressed():
	print("selected {0} {1}".format({'0':_selected, '1': ItemData.data[_selected]}))
	ItemData.data[_selected]

	$HTTPRequest.connect("request_completed", self, "_on_success_or_fail")
	if(_selected < 12):
		var query = JSON.print({"mint":mint, "item": ItemData.data[_selected]})
		$HTTPRequest.request("http://localhost:5000/buyitem",headers, false, HTTPClient.METHOD_POST, query)
	else:
		var query = JSON.print({"mint":mint, "tank": ItemData.data[_selected]})
		$HTTPRequest.request("http://localhost:5000/upgradetank",headers, false, HTTPClient.METHOD_POST, query)
	# Add 'Content-Type' header:

	
	
