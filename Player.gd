extends KinematicBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const fall_acceleration = 75
var speed = 400
var motion = Vector3()

# Called when the node enters the scene tree for the first time.
func _ready():
	motion = Vector3.ZERO


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	#translation += motion.normalized()*delta*speed
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()

func _physics_process(delta):
	var old_y = motion.y
	motion = Vector3(Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
	0,
	Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up"))
	motion = motion.normalized() * delta * speed
	motion.y = old_y - fall_acceleration * delta
	motion = move_and_slide(motion, Vector3.UP)
	
	
