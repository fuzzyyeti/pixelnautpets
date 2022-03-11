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
	$ShopLayer/Panel/PetShop/GridContainer.get_child(0).grab_focus()	
	$ShopLayer/Panel.hide()
	$HTTPRequest.connect("request_completed", self, "_on_request_completed")
	load_tank()
	$CoinCheckTimer.start(6)

func check_coins():
	var query = JSON.print({"mint":mint})
	# Add 'Content-Type' header:
	$HTTPRequest.request("http://localhost:5000/coinbalance",headers, false, HTTPClient.METHOD_GET, query)

func load_tank():
	var query = JSON.print({"mint":mint})
	# Add 'Content-Type' header:
	$HTTPRequest.request("http://localhost:5000/tank/load",headers, false, HTTPClient.METHOD_GET, query)
	

func update_items(items):
	print(items)
	for i in items:
		print(i.item)
		var texture = load('res://Shop/Assets/{0}.png'.format({'0':i.item}))
		var ti = TankItem.instance()
		var s = ti.get_node("ItemBody/Sprite")
		s.texture = texture
		ti.get_node("ItemBody/CollisionShape2D").shape.extents = Vector2(s.texture.get_width()/2, s.texture.get_height()/2)
		ti.get_node("ItemBody").position = Vector2(i.position.x, i.position.y)
		ti.get_node("ItemBody").item_type = i.item
		add_child(ti)
		ti.get_node("ItemBody").connect("position_update", self, "_on_position_update")
	
func _on_position_update(position, item_type):
	print('update position')
	print(position)
	var query = JSON.print({"mint":mint, "item": item_type, "x": position.x, "y": position.y})
	$HTTPRequest.request("http://localhost:5000/update/itemposition",headers, false, HTTPClient.METHOD_POST, query)
	
	
func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	if json.result.type == 'load':
		if not has_node('pixelnaut_0'):
			var attributes = json.result.orcanaut.attributes
			var pixelnaut: KinematicBody2D = Pixelnaut.instance()
			pixelnaut.name = 'Pixelnaut'
			var npc_motion = NPCMotion.new(rand_range(20,75), Vector2.RIGHT)
			pixelnaut.set_motion(npc_motion)
			pixelnaut.build_sprite(attributes)
			pixelnaut.position = Vector2(30,30)
			add_child(pixelnaut)
		update_items(json.result.tank.decorations)
		$CoinLabel.text = "{0} Coins".format({'0': json.result.coins})
	if json.result.type == 'coinbalance':
		$CoinLabel.text = "{0} Coins".format({'0': json.result.balance})
		if(json.result.coin_reset):
			$PopupLayer/PopupPanel/Label.text = "You waited too long to take care of your pixelnaut and lost all your coins"
			$PopupLayer/PopupPanel.popup_centered(Vector2(100,60))
			$PopupTimer.start(3)
	if json.result.type == 'buyitem':
		$CoinLabel.text = "{0} Coins".format({'0': json.result.balance})
		if json.result.result == 'success':
			$PopupLayer/PopupPanel/Label.text = "You bought a {0} for {1} coins".format(
				{'0': json.result.item.replace('_',' '), '1': json.result.cost})
			$PopupLayer/PopupPanel.popup_centered(Vector2(100,60))
			$PopupTimer.start(3)
		else:
			if json.result.cost == -1:
				$PopupLayer/PopupPanel/Label.text = "You already have a {1}".format(
					{'1': json.result.item.replace('_',' ')})
			else:	
				$PopupLayer/PopupPanel/Label.text = "You don't have enough coins to by a {1}".format(
					{'1': json.result.item.replace('_',' ')})
			$PopupLayer/PopupPanel.popup_centered(Vector2(100,60))
			$PopupTimer.start(3)
		load_tank()
	if json.result.type == 'feedfish':
			$CoinLabel.text = "{0} Coins".format({'0': json.result.balance})
			if(json.result.coins == -1):
				$PopupLayer/PopupPanel/Label.text = "You waited too long to feed your pixelnaut and lost all your coins"
			else:
				$PopupLayer/PopupPanel/Label.text = "You got {0} coins for feeding your pixelnaut".format(
			{'0': json.result.coins})
			$PopupLayer/PopupPanel.popup_centered(Vector2(100,60))
			$PopupTimer.start(3)
	if json.result.type == 'changewater':
			$CoinLabel.text = "{0} Coins".format({'0': json.result.balance})
			if(json.result.coins == -1):
				$PopupLayer/PopupPanel/Label.text = "You waited too long to change your pixelnaut's water and lost all your coins".format(
					{'0': json.result.coins})
			else:
				$PopupLayer/PopupPanel/Label.text = "You got {0} coins for changing your pixelnaut's water".format(
					{'0': json.result.coins})
			$PopupLayer/PopupPanel.popup_centered(Vector2(100,60))
			$PopupTimer.start(3)
			load_tank()
		

func _on_TextureButton_button_down(button):
	for c in $ShopLayer/Panel/PetShop/GridContainer.get_children():
		c.pressed = false
	for c in $ShopLayer/Panel/PetShop/GridContainer2.get_children():
		c.pressed = false
	print('button')
	print(button)
	_selected = button
	$ShopLayer/Panel/PetShop/HSplitContainer4/PriceLabel.text = "Price: {0} Coins".format({'0':ItemData.data[_selected][1]})


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
	$PopupLayer/PopupPanel.hide() # Replace with function body.


func _on_PetShopButton_pressed():
	if $ShopLayer/Panel.visible:
		$ShopLayer/Panel.hide()
	else:
		$ShopLayer/Panel.show()


func _on_FeedButton_pressed():
	var query = JSON.print({"mint":mint})
	$HTTPRequest.request("http://localhost:5000/feedfish",headers, false, HTTPClient.METHOD_POST, query)


func _on_CleanButton_pressed():
	var query = JSON.print({"mint":mint})
	$HTTPRequest.request("http://localhost:5000/changewater",headers, false, HTTPClient.METHOD_POST, query)


func _on_CoinCheckTimer_timeout():
	print("checking coins")
	check_coins()
