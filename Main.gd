extends Node2D
const Pixelnaut = preload("res://Pixelnauts/Pixelnaut.tscn")
const NPCMotion = preload("res://Pixelnauts/NPCMotion.gd")
const TankItem = preload("res://TankItem.tscn")
const POPUP_TIME = 5
var _selected = 0
const ItemDataScript = preload("res://ItemData.gd")
var ItemData = ItemDataScript.new()
const headers = ["Content-Type: application/json"]
var mint = "9eohkfSjLNd7GfU7wMoDA5RakpWbzHEodikdik9NHuMW"
var URL_BASE = "http://localhost:5000"
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var _add_mint_ref = JavaScript.create_callback(self, "add_mint")
var _add_api_url_ref = JavaScript.create_callback(self, "add_api_url")



# Called when the node enters the scene tree for the first time.
func _ready():
	var window = JavaScript.get_interface("window")
	if window:
		window.add_mint = _add_mint_ref
		window.add_api_url =  _add_api_url_ref
		window.godot_ready()
	$ShopLayer/Panel/PetShop/GridContainer.get_child(0).grab_focus()	
	$ShopLayer/Panel.hide()
	$HTTPRequest.connect("request_completed", self, "_on_request_completed")
	load_tank()
	$CoinCheckTimer.start(6)

func add_api_url(api_url):
	print('trying to update URL')
	if(api_url[0] and api_url[0] != ''):
		URL_BASE = api_url[0]
		print('Update URL BASE')
		print(URL_BASE)

func add_mint(mint_from_app):
	print("This is from godot")
	print("adding mint {0}".format({'0':mint_from_app}))
	mint = mint_from_app[0]
	if has_node('pixelnaut_0'):
		remove_child(get_node('pixelnaut_0'))
	load_tank()


func check_coins():
	# Add 'Content-Type' header:
	$HTTPRequest.request(URL_BASE + "/coinbalance?mint={0}".format({'0':mint}),headers, false, HTTPClient.METHOD_GET)

func load_tank():
	# Add 'Content-Type' header:
	$HTTPRequest.request(URL_BASE + "/tank/load?mint={0}".format({'0':mint}),headers, false, HTTPClient.METHOD_GET)
	

func _physics_process(delta):
	var already_picked = false
	for i in get_children():
		if i.name.begins_with('item'):
			if i.get_node('ItemBody').can_grab:
				if already_picked:
					i.get_node('ItemBody').can_grab = false
				else:
					already_picked = true

func update_items(items):
	for i in get_children():
		if i.name.begins_with('item'):
			remove_child(i)
	var j = 0
	for i in items:
		var	texture = load('res://Shop/Assets/{0}.png'.format({'0':i.item}))
		var ti = TankItem.instance()
		ti.name = 'item {0}'.format({'0':j})
		j += 1
		var s = ti.get_node("ItemBody/Sprite")
		s.texture = texture
		print(s.texture.to_string())
		ti.get_node("ItemBody").position = Vector2(i.position.x, i.position.y)
		ti.get_node("ItemBody").item_type = i.item
		ti.get_node("ItemBody/CollisionShape2D").shape = RectangleShape2D.new()
		ti.get_node("ItemBody").connect("position_update", self, "_on_position_update")
		add_child(ti)
		if i.item == 'tv':
			print('set tv')
			print(ti.get_node("ItemBody/CollisionShape2D").shape)
			print(ti)
			ti.get_node("ItemBody").animate('slow', 6)
			ti.get_node("ItemBody/CollisionShape2D").shape.extents = Vector2(s.texture.get_width()/12, s.texture.get_height()/2)
		elif i.item in ['kelp']:
			ti.get_node("ItemBody").animate('fast', 10)
			ti.get_node("ItemBody/CollisionShape2D").shape.extents = Vector2(9,16)
			ti.get_node("ItemBody/CollisionShape2D").position = Vector2(18,3)
		elif i.item in ['atlas_ship', 'orca_mug','hog_pet','samo_pet','scallop']:
			ti.get_node("ItemBody").animate('fast', 10)
			ti.get_node("ItemBody/CollisionShape2D").shape.extents = Vector2(5,8)
			ti.get_node("ItemBody/CollisionShape2D").position = Vector2(14,12)
		elif i.item in ['phantom_ghost']:
			ti.get_node("ItemBody").animate('fast', 10)
			ti.get_node("ItemBody/CollisionShape2D").shape.extents = Vector2(7,6)
			ti.get_node("ItemBody/CollisionShape2D").position = Vector2(11,-10)
		elif i.item in ['sbr_saber']:
			ti.get_node("ItemBody").animate('fast', 10)
			ti.get_node("ItemBody/CollisionShape2D").shape.extents = Vector2(9,16)
			ti.get_node("ItemBody/CollisionShape2D").position = Vector2(12,10)
		elif i.item in ['sol_beach_ball']:
			ti.get_node("ItemBody").animate('fast', 10)
			ti.get_node("ItemBody/CollisionShape2D").shape.extents = Vector2(7,8)
			ti.get_node("ItemBody/CollisionShape2D").position = Vector2(11,-5)
		elif i.item in ['coral']:
			ti.get_node("ItemBody").animate('fast', 10)
			ti.get_node("ItemBody/CollisionShape2D").shape.extents = Vector2(6,11)
			ti.get_node("ItemBody/CollisionShape2D").position = Vector2(18,11)
		else:
			print('set main')
			print(ti.get_node("ItemBody/CollisionShape2D").shape)
			print(ti)
			ti.get_node("ItemBody/CollisionShape2D").shape.extents = Vector2(s.texture.get_width()/2, s.texture.get_height()/2)
			ti.get_node("ItemBody").one_frame()
		if i.item == 'lamp':
			ti.get_node("ItemBody/Sprite").hframes = 2
			ti.get_node("ItemBody/Sprite").frame = 1
func update_tank(type):
	var t = get_node('tank')
	remove_child(t)
	#for i in get_children():
#		if i.name.begins_with('tank'):
	#		remove_child(i)
	if(type == 'bag'):
		var tank_scene = load('res://Tanks/tank-tier_0.tscn')
		var tank = tank_scene.instance()
		tank.position = Vector2(171,77)
		tank.name = 'tank'
		add_child(tank)
	if(type == 'fish_bowl'):
		var tank_scene = load('res://Tanks/tank-tier_1.tscn')
		var tank = tank_scene.instance()
		tank.position = Vector2(171,77)
		tank.name = 'tank'
		add_child(tank)
	if(type == 'basic_aquarium'):
		var tank_scene = load('res://Tanks/tank-tier_2.tscn')
		var tank = tank_scene.instance()
		tank.position = Vector2(171,77)
		tank.name = 'tank'
		add_child(tank)
	if(type == 'wide_aquarium'):
		var tank_scene = load('res://Tanks/tank-tier_3.tscn')
		var tank = tank_scene.instance()
		tank.position = Vector2(171,77)
		tank.name = 'tank'
		add_child(tank)
	
func _on_position_update(position, item_type):
	print('update position')
	print(position)
	var query = JSON.print({"mint":mint, "item": item_type, "x": position.x, "y": position.y})
	$HTTPRequest.request(URL_BASE + "/update/itemposition",headers, false, HTTPClient.METHOD_POST, query)
#	if item_type == 'lamp':
#		ti.get_node("ItemBody/Sprite").hframes = 2
#		ti.get_node("ItemBody/Sprite").frame = 1
	
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
			pixelnaut.position = Vector2(150,100)
			pixelnaut.z_index = 100
			add_child(pixelnaut)
		update_tank(json.result.tank.type)
		update_items(json.result.tank.decorations)
		$CoinLabel.text = "{0} Coins".format({'0': json.result.coins})
		check_coins()
	if json.result.type == 'coinbalance':
		if json.result.coin_reset and $CoinLabel.text != '0 Coins':
			$PopupLayer/PopupPanel/GridContainer/MarginContainer/Label.text = "You waited too long to take care of your pixelnaut and lost all your coins"
			$PopupLayer/PopupPanel.popup_centered(Vector2(100,100))
			$PopupTimer.start(POPUP_TIME)
		$CoinLabel.text = "{0} Coins".format({'0': json.result.balance})
	if json.result.type == 'buyitem' or json.result.type == 'upgradetank':
		$CoinLabel.text = "{0} Coins".format({'0': json.result.balance})
		if json.result.result == 'success':
			$PopupLayer/PopupPanel/GridContainer/MarginContainer/Label.text = "You bought a {0} for {1} coins".format(
				{'0': json.result.item.replace('_',' '), '1': json.result.cost})
			$PopupLayer/PopupPanel.popup_centered(Vector2(100,60))
			$PopupTimer.start(POPUP_TIME)
		else:
			if json.result.cost == -1:
				$PopupLayer/PopupPanel/GridContainer/MarginContainer/Label.text = "You already have a {1}".format(
					{'1': json.result.item.replace('_',' ')})
			else:	
				$PopupLayer/PopupPanel/GridContainer/MarginContainer/Label.text = "You don't have enough coins to buy a {1}".format(
					{'1': json.result.item.replace('_',' ')})
			$PopupLayer/PopupPanel.popup_centered(Vector2(100,60))
			$PopupTimer.start(POPUP_TIME)
		load_tank()
	if json.result.type == 'feedfish':
			$CoinLabel.text = "{0} Coins".format({'0': json.result.balance})
			if(json.result.coins == -1):
				$PopupLayer/PopupPanel/GridContainer/MarginContainer/Label.text = "You waited too long to feed your pixelnaut and lost all your coins"
			else:
				$PopupLayer/PopupPanel/GridContainer/MarginContainer/Label.text = "You got {0} coins for feeding your pixelnaut".format(
			{'0': json.result.coins})
			$PopupLayer/PopupPanel.popup(Rect2(202,6,150,100))
			$PopupTimer.start(POPUP_TIME)
	if json.result.type == 'changewater':
			$CoinLabel.text = "{0} Coins".format({'0': json.result.balance})
			if(json.result.coins == -1):
				$PopupLayer/PopupPanel/GridContainer/MarginContainer/Label.text = "You waited too long to change your pixelnaut's water and lost all your coins".format(
					{'0': json.result.coins})
			else:
				$PopupLayer/PopupPanel/GridContainer/MarginContainer/Label.text = "You got {0} coins for changing your pixelnaut's water".format(
					{'0': json.result.coins})
			$PopupLayer/PopupPanel.popup(Rect2(202,6,150,100))
			$PopupTimer.start(POPUP_TIME)
			#load_tank()
		

func _on_TextureButton_button_down(button):
	for c in $ShopLayer/Panel/PetShop/GridContainer.get_children():
		c.pressed = false
	for c in $ShopLayer/Panel/PetShop/GridContainer2.get_children():
		c.pressed = false
	print('button')
	print(button)
	_selected = button
	$ShopLayer/Panel/PetShop/GridContainer3/PriceLabel.text = "Price: {0} Coins".format({'0':ItemData.data[_selected][1]})


func _on_BuyButton_pressed():
	print("selected {0} {1}".format({'0':_selected, '1': ItemData.data[_selected][0]}))
	if(_selected < 12):
		var query = JSON.print({"mint":mint, "item": ItemData.data[_selected][0]})
		$HTTPRequest.request(URL_BASE + "/buyitem",headers, false, HTTPClient.METHOD_POST, query)
	else:
		var query = JSON.print({"mint":mint, "tank": ItemData.data[_selected][0]})
		$HTTPRequest.request(URL_BASE + "/upgradetank",headers, false, HTTPClient.METHOD_POST, query)
	# Add 'Content-Type' header:

	
	


func _on_PopupTimer_timeout():
	$PopupLayer/PopupPanel.hide()
	get_node('pixelnaut_0').show() 
func _on_TextureButton_pressed():
	$PopupLayer/PopupPanel.hide() 

func _on_PetShopButton_pressed():
	if $ShopLayer/Panel.visible:
		$ShopLayer/Panel.hide()
	else:
		$ShopLayer/Panel.show()


func _on_FeedButton_pressed():
	var query = JSON.print({"mint":mint})
	$HTTPRequest.request(URL_BASE + "/feedfish",headers, false, HTTPClient.METHOD_POST, query)
	get_node('tank/AnimationPlayer').play("Food")
	get_node('pixelnaut_0').speed_offset = 40
	$FeedTimer.start(10)
	$CleanButton.disabled = true
	$FeedButton.disabled = true
	
func _on_CleanButton_pressed():
	var query = JSON.print({"mint":mint})
	$HTTPRequest.request(URL_BASE + "/changewater",headers, false, HTTPClient.METHOD_POST, query)
	get_node('tank/AnimationPlayer').play("Clean")
	get_node('pixelnaut_0').hide()
	$FeedTimer.start(10)
	$CleanButton.disabled = true
	$FeedButton.disabled = true
	
func _on_CoinCheckTimer_timeout():
	print("checking coins")
	check_coins()


func _on_store_button_pressed():
	$ShopLayer/Panel.hide()


func _on_FeedTimer_timeout():
	get_node('pixelnaut_0').speed_offset = 0
	$CleanButton.disabled = false
	$FeedButton.disabled = false
