extends Line2D

var rope_length: float = 10
var direction: Vector2
var is_rope_active: bool= true
var speed: float = 10

func _ready():
	get_node("/root/Main/Ball").connect("update_state", self, "on_update_state")
	pass
	
func _physics_process(delta):
	var last_point: Vector2 = points[points.size()-1]
	var lastSec_point: Vector2 = points[points.size()-2]
	var nextPoint: Vector2 = last_point+lastSec_point.direction_to(last_point)*rope_length*delta
	if lastSec_point.distance_to(nextPoint) >= rope_length :
		add_point(nextPoint)
		remove_point(0)

func on_update_state(new_direction: Vector2):
	if is_rope_active:
		direction = new_direction
		position-=direction*rope_length*speed*get_physics_process_delta_time()
		
