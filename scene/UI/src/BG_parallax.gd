extends ParallaxBackground


func _ready():
#	scroll_offset = Vector2(0,0)
	get_tree().get_root().connect("size_changed", self, "_on_size_changed")
	
func _on_size_changed():
	
	pass

