extends KinematicBody


const fall_acceleration = 75
var speed = 600
var motion = Vector3()
var max_health = 3
var health = max_health
var bullets = 6
var invuln = false
var is_reload = false
var is_dodge = false
onready var hp_sp = get_node("/root/World/HUD/Health")
onready var bul_sp = get_node("/root/World/HUD/Bullets")
onready var cam = get_node("/root/World/Camera")
onready var debug_text = get_node("/root/World/HUD/DebugText")
onready var bulletScene = preload("res://Code/Bullet.tscn")
onready var world = get_node("/root/World")

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
		return true
	else:
		return false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	#translation += motion.normalized()*delta*speed
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()
	
	if Input.is_action_just_pressed("dodge") and not is_dodge:
		is_dodge = true
		debug_text.text = "Dodging"
		debug_text.visible = true
		invuln = true
		$DodgeTimer.start()
	
	var mouse_pos = get_viewport().get_mouse_position()
	var lookat_pos = cam.project_ray_origin(mouse_pos)
	lookat_pos += cam.project_ray_normal(mouse_pos) * (cam.global_transform.origin.y - global_transform.origin.y )
	#lookat_pos = get_world().direct_space_state.intersect_ray
	var aim_look = Vector3(lookat_pos.x, global_transform.origin.y, lookat_pos.z)
	$an.look_at(aim_look, Vector3.UP)
	var camrot = $an.rotation_degrees.x
	#$an.rotation.x -= PI/4
	#$an.look_at(lookat_pos, Vector3.UP)

	
	if not is_reload and not is_dodge:
		if Input.is_action_just_pressed("shoot"):
			if(bullets > 0):
				var poolya = bulletScene.instance()
				poolya.global_transform = $an.global_transform
				add_collision_exception_with(poolya)
				get_tree().get_root().add_child(poolya)
				bullets -= 1
				bul_sp.set_frame(bullets)
		
		if Input.is_action_just_pressed("reload"):
			debug_text.text = "Reloading"
			debug_text.visible = true
			is_reload = true
			$ReloadTimer.start()

func _physics_process(delta):
	var old_y = motion.y
	if not is_dodge:
		motion = Vector3(Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		0,
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up"))
		motion = motion.normalized() * delta * speed
	motion.y = old_y - fall_acceleration * delta
	motion *= world.timescale
	motion = move_and_slide(motion + knock_dir, Vector3.UP)
	
	
func is_player():
	return true


func _on_InvulnTimer_timeout():
	$CSGBox.material.flags_transparent = false
	invuln = false

func _on_KnockTimer_timeout():
	knock_dir = Vector3.ZERO

func _on_ReloadTimer_timeout():
	bullets = 6
	bul_sp.set_frame(bullets)
	debug_text.visible = false
	is_reload = false

func _on_DodgeTimer_timeout():
	is_dodge = false
	invuln = false
	debug_text.visible = false
