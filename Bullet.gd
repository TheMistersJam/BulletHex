extends KinematicBody


const SPEED = 15

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	var moveVec = Vector3(sin(rotation.y + PI), 0, cos(rotation.y + PI))
	moveVec = moveVec.normalized() * SPEED * delta
	var col = move_and_collide(moveVec)
	if col:
		if not col.collider.has_method("is_player"):
			queue_free()
