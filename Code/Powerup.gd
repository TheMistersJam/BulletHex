extends Area

enum p_types {
	SPEED,
	RELOAD_SPEED,
	PENETRATION,
	HEATH,
	DAMAGE,
	MAX_POWERUPS,
}

var power_type = randi()%p_types.MAX_POWERUPS

func _ready():
	set_power_type(power_type)


func set_power_type(ptype):
	if ptype >= p_types.MAX_POWERUPS:
		ptype = randi()%p_types.MAX_POWERUPS
	$AnimatedSprite3D.frame = ptype
	power_type = ptype

func _on_Spatial_body_entered(body):
	if body.has_method("is_player"):
		apply_powerup(body)
		queue_free()
		
func apply_powerup(p):
	match(power_type):
		p_types.SPEED:
			p.speed += 100
		p_types.RELOAD_SPEED:
			pass #TODO
		p_types.PENETRATION:
			pass #TODO
		p_types.HEATH:
			p.health = p.max_health
		p_types.DAMAGE:
			pass

