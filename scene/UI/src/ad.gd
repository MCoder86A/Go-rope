extends Node

signal _on_ad_reward(curr, am)
signal _on_ad_closed()
signal _on_ad_loaded()


var ad_Unit_name : String = "GetCoin"

func _ready():
	if OS.get_name() == "Android":
		MobileAds.connect("rewarded_ad_failed_to_load", self, "_on_r_f")
		MobileAds.connect("user_earned_rewarded", self, "_on_reward")
		MobileAds.connect("rewarded_ad_loaded", self, "_on_MobileAds_rewarded_ad_loaded")
		MobileAds.connect("rewarded_ad_closed", self, "_on_MobileAds_rewarded_ad_closed")
		var inGameui : Control = get_tree().get_root().get_node("/root/Main/UI/inGameUI")
		inGameui.connect("show_ad", self, "show_ad")
		MobileAds.load_rewarded(ad_Unit_name)

func show_ad():
	MobileAds.show_rewarded()

func _on_reward(curr:String, am:int):
	emit_signal("_on_ad_reward", curr, am)
	
func _on_MobileAds_rewarded_ad_loaded():
	emit_signal("_on_ad_loaded")


func _on_MobileAds_rewarded_ad_closed() -> void:
	MobileAds.load_rewarded(ad_Unit_name)
	emit_signal("_on_ad_closed")

func _on_r_f(code):
	print("Failed ", code)
	
