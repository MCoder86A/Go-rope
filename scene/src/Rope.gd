extends Line2D

var rope_length: float = 60
var direction: Vector2
var is_rope_active: bool= true
var speed: float = 10
var nextPoint: Vector2 = Vector2.ZERO

func _ready():
	get_node("/root/Main/Ball").connect("update_state", self, "on_update_state")
	pass
	
func _physics_process(delta):
	var last_point: Vector2 = points[points.size()-1]
	var lastSec_point: Vector2 = points[points.size()-2]
	nextPoint += (lastSec_point.direction_to(last_point)*rope_length*delta)
	if nextPoint.length() >= 10 :
		add_point(last_point+nextPoint)
		nextPoint.y = rope_length
		position-=nextPoint*direction
		nextPoint = Vector2(0,0)
		remove_point(0)

func on_update_state(new_direction: Vector2):
	if is_rope_active:
		direction = new_direction
