extends Node2D
const Pixelnaut = preload("res://Pixelnauts/Pixelnaut.tscn")
const NPCMotion = preload("res://Pixelnauts/NPCMotion.gd")
const TankItem = preload("res://TankItem.tscn")
var _selected = 0
const ItemDataScript = preload("res://ItemData.gd")
var ItemData = ItemDataScript.new()
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

	$Panel.hide()
	

func update_items(items):
	print(items)
	for i in items:
		print(i.item)
		var texture = load('res://Shop/Assets/{0}.png'.format({'0':i.item}))
		var ti = TankItem.instance()
		var s = ti.get_node("ItemBody/Sprite")
		s.texture = texture
		ti.get_node("ItemBody/CollisionShape2D").shape.extents = Vector2(s.texture.get_width(), s.texture.get_height())
		ti.position = Vector2(i.position.x, i.position.y)
		ti.get_node("ItemBody").item_type = i.item
		add_child(ti)
		ti.get_node("ItemBody").connect("position_update", self, "_on_position_update")
	
func _on_position_update(position, item_type):
	var query = JSON.print({"mint":mint, "item": item_type, "x": position.x, "y": position.y})
	$HTTPRequest.request("http://localhost:5000/update/itemposition",headers, false, HTTPClient.METHOD_POST, query)
	
	
func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	if(json.result.type == 'load'):
		var a = json.result.orcanaut.attributes
		
		var pixelnaut: KinematicBody2D = Pixelnaut.instance()

		var npc_motion = NPCMotion.new(rand_range(20,75), Vector2.RIGHT)
		pixelnaut.set_motion(npc_motion)
		pixelnaut.build_sprite(a)
		pixelnaut.position = Vector2(200,200)
		add_child(pixelnaut)
		update_items(json.result.tank.decorations)
	if(json.result.type == 'buyitem'):
		if(json.result.result == 'success'):
			$PopupPanel/Label.text = "You bought a {0} for {1} coins".format(
				{'0': json.result.item.replace('_',' '), '1': json.result.cost})
			$PopupPanel.popup_centered(Vector2(100,100))
			$PopupTimer.start(3)
		else:
			if json.result.cost == -1:
				$PopupPanel/Label.text = "You already have a {1}".format(
					{'1': json.result.item.replace('_',' ')})	
			else:	
				$PopupPanel/Label.text = "You don't have enough coins to by a {1}".format(
					{'1': json.result.item.replace('_',' ')})
			$PopupPanel.popup_centered(Vector2(100,100))
			$PopupTimer.start(3)

func _on_TextureButton_button_down(button):
	for c in $Panel/PetShop/GridContainer.get_children():
		c.pressed = false
	for c in $Panel/PetShop/GridContainer2.get_children():
		c.pressed = false
	print('button')
	print(button)
	_selected = button
	$Panel/PetShop/HSplitContainer4/PriceLabel.text = "Price: {0} Coins".format({'0':ItemData.data[_selected][1]})


func _on_BuyButton_pressed():
	print("selected {0} {1}".format({'0':_selected, '1': ItemData.data[_selected][0]}))


	if(_selected < 12):
		var query = JSON.print({"mint":mint, "item": ItemData.data[_selected][0]})
		$HTTPRequest.request("http://localhost:5000/buyitem",headers, false, HTTPClient.METHOD_POST, query)
	else:
		var query = JSON.print({"mint":mint, "tank": ItemData.data[_selected][0]})
		$HTTPRequest.request("http://localhost:5000/upgradetank",headers, false, HTTPClient.METHOD_POST, query)
	# Add 'Content-Type' header:

	
	


func _on_PopupTimer_timeout():
	$PopupPanel.hide() # Replace with function body.
