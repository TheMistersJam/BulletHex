extends KinematicBody


const SPEED = 15
var damage = 10
onready var world = get_node("/root/World")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	var moveVec = Vector3(sin(rotation.y + PI), 0, cos(rotation.y + PI))
	moveVec = moveVec.normalized() * SPEED * delta * world.timescale
	var col = move_and_collide(moveVec)
	if col:
		if not col.collider.has_method("is_player"):
			if col.collider.has_method("on_hit"):
				col.collider.on_hit(damage)
				queue_free()
			else:
				queue_free()
