extends KinematicBody2D

signal Extend_rope(position)
signal heading_toward()
# Import variable
export var speed: float = 10
export var path_p: NodePath

#Game state
var direction: Vector2 = Vector2(1,0)

# Resources
var path: Node2D
var res_Rope = load("res://scene/Rope.tscn")
var ropes: Array

func drawLine(Rope: Line2D, firstPoint: Vector2, secondPoint: Vector2):
	for i in firstPoint.distance_to(secondPoint) :
		Rope.add_point(firstPoint.move_toward(secondPoint, 50))

func _ready():
	path = get_node(path_p)
	Rope_init()

func _process(delta):
	#Update_rope(delta)
	pass
	
func _physics_process(delta):
	if Input.get_action_strength("wasd"):
		direction.x = Input.get_action_strength("right")-Input.get_action_strength("left")
		direction.y = Input.get_action_strength("down")-Input.get_action_strength("up")
	position+=direction*speed*delta
	emit_signal("Extend_rope", position)
	
func Rope_init():
	var Rope: Line2D = res_Rope.instance()
	path.add_child(Rope)
	ropes.append(Rope)
	
	for i in range(-200, 201, 400):
		Rope.add_point(Vector2(position.x+i, position.y))
	emit_signal("heading_toward")
	
func Update_rope(delta: float):
	for rope in ropes:
		rope.position-=direction
	
	
	
	
	
	
	
	
	
	
	
	
