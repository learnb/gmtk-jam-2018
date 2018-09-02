extends "Mob.gd"
# Power-Up / Mob

var dead

func _ready():
	speed = 0
	scale = Vector2(0.35, 0.35)
	dead = false
	add_to_group("powerups")
	play_spawn_sfx()

func _process(delta):
	pass

func die():
	if not dead:
		dead = true
		if not get_parent().gameover:
			get_parent().powerup += 1
		get_parent().stats_D[1] += 1
		hide()
		$CollisionShape2D.disabled = true
		queue_free()
