extends "Mob.gd"
# Move only Mob

var dead

func _ready():
	speed = 100
	scale = Vector2(0.35, 0.35)
	dead = false
	add_to_group("mobs")
	play_spawn_sfx()

func _process(delta):
	pass

func die():
	if not dead:
		dead = true
		get_parent().stats_A[1] += 1
		hide()
		$CollisionShape2D.disabled = true
		queue_free()
