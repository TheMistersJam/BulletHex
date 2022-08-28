extends KinematicBody

var hp = 30
var state = 0
var speed = 100
onready var tim = $Timer
var pouncePos = Vector3()
onready var player = get_tree().get_root().get_node("World/Player")
onready var world = get_tree().get_root().get_node("World")
onready var cmod = $CSGBox
var t = 0
var isShake = false
var hitDir_l

func _ready():
	pass

func shakeTween(x, a, b, c):
	return a*(exp(-c*x))*(cos(b*x))

func local_shake(hitDir):
	hitDir_l = hitDir.normalized()
	$Timer.paused = true
	isShake = true
	$Tween.interpolate_property(self, "t", 0, 0.2, 0.2, Tween.TRANS_LINEAR)
	$Tween.start()

func on_hit(damage, hitDir):
	hp -= damage
	$CSGBox.material.flags_transparent = true
	#world.flash_slow() #TODO: replace with local flash slow
	local_shake(hitDir)
	$FlashTimer.start()
	if hp <= 0:
		#probably do something fancier than just deleting itself
		#var world = get_tree().get_root().get_node("World")
		#world.guy_dead()
		#var dieSound
		#if world.countdown <= 0:
		#	dieSound = $Die2.duplicate()
		#else:
		#	dieSound = $Die1.duplicate()
		#world.add_child(dieSound)
		#dieSound.position = position
		#dieSound.play()
		world.remove_enemy()
		queue_free()

func _process(delta):
	if isShake:
		cmod.translation = hitDir_l*shakeTween(t, 0.4, 70, 1) #need to make these const

func _physics_process(delta):
	#move_and_slide((pouncePos - position)* speed *delta)
	if not isShake:
		move_and_slide(pouncePos* speed *delta * world.timescale)
		for col_i in get_slide_count():
			var col = get_slide_collision(col_i).collider
			if col.has_method("is_player"):
				if col.get_damaged(1, true, pouncePos.normalized()):
					#This sucks, the model still slides against the player even if knockback is not applied and its not good
					#Maybe do some collision masks or something
					state = 4
					$Timer.stop()
					_on_Timer_timeout()
		move_and_slide(Vector3(0, -1, 0)*delta * world.timescale *1000)

func _on_Timer_timeout():
	match state:
		0:
			#$Sprite.play("walk")
			#anim.play("idle") #maybe should be walking
			pouncePos = Vector3((randf()*2)-1, 0, (randf()*2)-1)
			pouncePos = pouncePos.normalized()
			speed = 500
			state = 1
			tim.set_wait_time((randf()*1) + 1)
			tim.start()
		1:
			#$Sprite.play("default")
			speed = 0
			#anim.play("shake")
			state = 2
		2:
			#$Sprite.play("walk")
			#tw.interpolate_property(self, "speed", 0, SPEED_MAX, STATE_TIME, Tween.TRANS_QUART, Tween.EASE_IN_OUT)
			speed = 2000
			pouncePos = player.translation - translation
			pouncePos.y = 0
			pouncePos = pouncePos.normalized()
			#tw.start()
			#tim.stop()
			#anim.play("pounce") #, -1, 0.7)
			#$SoundAttack.play()
			tim.set_wait_time(0.9)
			tim.start()
			state = 3
		3:
			#$Sprite.play("default")
			speed = 0
			#anim.play("idle")
			tim.set_wait_time(0.5)
			tim.start()
			state = 0
		4:
			pouncePos = pouncePos.normalized()
			speed = -400
			tim.set_wait_time(0.2)
			tim.start()
			state = 3


func _on_FlashTimer_timeout():
	$CSGBox.material.flags_transparent = false


func _on_Tween_tween_all_completed():
	t = 0
	cmod.translation = Vector3.ZERO
	isShake = false
	$Timer.paused = false
