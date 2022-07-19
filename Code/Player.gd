extends KinematicBody


const fall_acceleration = 75
var speed = 600
var motion = Vector3()
var health = 3
var bullets = 6
var invuln = false
onready var hp_sp = get_node("/root/World/HUD/Health")
onready var bul_sp = get_node("/root/World/HUD/Bullets")
onready var cam = get_node("/root/World/Camera")
onready var bulletScene = preload("res://Code/Bullet.tscn")

var knock_dir = Vector3()

func _ready():
	$CSGBox.material.flags_transparent = false
	hp_sp.set_frame(health)
	bul_sp.set_frame(bullets)
	motion = Vector3.ZERO

func get_damaged(damage,knock=false,knock_vec=null):
	if not invuln:
		health -= damage
		hp_sp.set_frame(health)
		if knock:
			knock_dir = damage * knock_vec * 30
			$KnockTimer.start()
		$CSGBox.material.flags_transparent = true
		invuln = true
		$InvulnTimer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	#translation += motion.normalized()*delta*speed
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()

	var mouse_pos = get_viewport().get_mouse_position()
	var lookat_pos = cam.project_ray_origin(mouse_pos)
	lookat_pos += cam.project_ray_normal(mouse_pos) * (cam.global_transform.origin.y - global_transform.origin.y )
	#lookat_pos = get_world().direct_space_state.intersect_ray
	var aim_look = Vector3(lookat_pos.x, global_transform.origin.y, lookat_pos.z)
	$an.look_at(aim_look, Vector3.UP)
	var camrot = $an.rotation_degrees.x
	#$an.rotation.x -= PI/4
	#$an.look_at(lookat_pos, Vector3.UP)
	if Input.is_action_just_pressed("shoot"):
		if(bullets > 0):
			var poolya = bulletScene.instance()
			poolya.global_transform = $an.global_transform
			add_collision_exception_with(poolya)
			get_tree().get_root().add_child(poolya)
			bullets -= 1
			bul_sp.set_frame(bullets)
	
	if Input.is_action_just_pressed("reload"):
		bullets = 6
		bul_sp.set_frame(bullets)

func _physics_process(delta):
	var old_y = motion.y
	motion = Vector3(Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
	0,
	Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up"))
	motion = motion.normalized() * delta * speed
	motion.y = old_y - fall_acceleration * delta
	motion = move_and_slide(motion + knock_dir, Vector3.UP)
	
	
func is_player():
	return true


func _on_InvulnTimer_timeout():
	$CSGBox.material.flags_transparent = false
	invuln = false


func _on_KnockTimer_timeout():
	knock_dir = Vector3.ZERO
