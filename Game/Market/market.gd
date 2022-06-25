extends Control

var db_name: String = "score_dbv1.2.3"
var gold : int
var active_item : String
var showing_item : TextureRect


var item_dict :Dictionary = {
	1: "item",
	2: "item2"
}

func _ready():
	if not GameDb._is_db_exist(db_name):
		GameDb._create_db(db_name,
		'{'+
			'"MAX_SCORE": 0,'+
			'"LAST_SCORE": 0,'+
			'"GOLD": 0,'+
			'"CHARACTER": 1,'+
			'"PURCHASED": ["item"],'+
			'"SOUND": 1'+
		'}')
	GameDb._open_db(db_name)
	gold = GameDb._get_db(db_name)["GOLD"]
	$no_of_coin.text = String(round(gold))
	
	var i :int = GameDb._get_db(db_name)["CHARACTER"]
	active_item = item_dict[i]
	var item_array = $items.get_children()
	for item in item_array:
		if item.name == active_item:
			showing_item = item

	
	for item in $items.get_children():
		if item.get_name() == active_item:
			item.show()
			$AcctiveItem.show()
			$Select.show()
			$Unlock.hide()


func _on_right_pressed():
	var item_array = $items.get_children()
	var next_item2show: int
	var purchased_array = GameDb._get_db(db_name)["PURCHASED"]
	
	for item in item_array:
		if item.is_visible():
			item.hide()
			next_item2show	= (item_array.find(item)+1)%\
				item_array.size()
			if purchased_array.find(item_array[next_item2show].name) > -1:
				$Unlock.hide()
				$Select.show()
			else :
				$Unlock.show()
				$Select.hide()
	
	item_array[next_item2show].show()
	if item_array[next_item2show].name == active_item:
		$AcctiveItem.show()
	else:
		$AcctiveItem.hide()
	
	showing_item = item_array[next_item2show]


func _on_left_pressed():
	var item_array = $items.get_children()
	var next_item2show: int
	var purchased_array = GameDb._get_db(db_name)["PURCHASED"]
	
	for item in item_array:
		if item.is_visible():
			item.hide()
			next_item2show	= (item_array.find(item)-1)%\
				item_array.size()
			if purchased_array.find(item_array[next_item2show].name) > -1:
				$Unlock.hide()
				$Select.show()
			else :
				$Unlock.show()
				$Select.hide()
	
	item_array[next_item2show].show()
	if item_array[next_item2show].name == active_item:
		$AcctiveItem.show()
	else:
		$AcctiveItem.hide()
	
	showing_item = item_array[next_item2show]


func _on_Unlock_pressed():
	if gold >= 2000:
		var after_sale_gold: int = gold-2000 
		GameDb._update(db_name, "GOLD", after_sale_gold)
		gold = GameDb._get_db(db_name)["GOLD"]
		$no_of_coin.text = String(round(gold))
		var purchased : Array = GameDb._get_db(db_name)["PURCHASED"]
		purchased.append(showing_item.name)
		GameDb._update(db_name, "PURCHASED", purchased)
		$Unlock.hide()
		$Select.show()
		_on_Select_pressed()
		if($Toast/player.is_playing()):
			$Toast/player.stop()
		$Toast/Label.text = "Player unlocked"
		$Toast/player.play("make_toast")
		GameDb._save_db(db_name)
	else:
		if($Toast/player.is_playing()):
			$Toast/player.stop()
		$Toast/Label.text = "Not enough coins"
		$Toast/player.play("make_toast")
	


func _on_Select_pressed():
	if showing_item.name == active_item:
		if($Toast/player.is_playing()):
			$Toast/player.stop()
		$Toast/Label.text = "Already selected"
		$Toast/player.play("make_toast")
		return

	var vl: Array = item_dict.values()
	var idx: int = vl.find(showing_item.name)
	GameDb._update(db_name, "CHARACTER", idx+1)
	$AcctiveItem.show()
	active_item = showing_item.name
	if($Toast/player.is_playing()):
		$Toast/player.stop()
	$Toast/Label.text = "Player selected"
	$Toast/player.play("make_toast")
	GameDb._save_db(db_name)
	


func _on_Start_pressed():
	get_tree().change_scene("res://Game/Loading/loading.tscn")


func _notification(what):
	var is_trigger :bool = (
			what == MainLoop.NOTIFICATION_APP_PAUSED ||
			what == MainLoop.NOTIFICATION_CRASH ||
			what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST ||
			what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST ||
			what == MainLoop.NOTIFICATION_WM_FOCUS_OUT ||
			what == MainLoop.NOTIFICATION_WM_MOUSE_EXIT
		)
	if is_trigger:
		GameDb._save_db(db_name)


