extends KinematicBody

var hp = 30
var state = 0
var speed = 100
onready var tim = $Timer
var pouncePos = Vector3()
onready var player = get_tree().get_root().get_node("World/Player")

func _ready():
	pass

func on_hit(damage):
	hp -= damage
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
		queue_free()

func _physics_process(delta):
	#move_and_slide((pouncePos - position)* speed *delta)
	var col = move_and_slide(pouncePos* speed *delta)

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
			speed = 5000
			pouncePos = player.translation - translation
			pouncePos.y = 0
			pouncePos = pouncePos.normalized()
			#tw.start()
			#tim.stop()
			#anim.play("pounce") #, -1, 0.7)
			#$SoundAttack.play()
			tim.set_wait_time(0.4)
			tim.start()
			state = 3
		3:
			#$Sprite.play("default")
			speed = 0
			#anim.play("idle")
			tim.set_wait_time(0.5)
			tim.start()
			state = 0
