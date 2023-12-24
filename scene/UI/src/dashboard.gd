extends Control

func _ready():
	var rect = get_viewport_rect()
	if rect.size.x <= rect.size.y:
		$r_guide.show()



func _on_play_button_down():
	get_tree().change_scene("res://Game/Market/market.tscn")


func _on_dashboard_resized():
	var rect = get_viewport_rect()
	if rect.size.x <= rect.size.y:
		$r_guide.show()
	else:
		$r_guide.hide()
	
