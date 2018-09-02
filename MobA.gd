extends "Mob.gd"
# Move only Mob

func _ready():
	speed = 100
	scale = Vector2(0.35, 0.35)
	pass

func _process(delta):
	pass

func die():
	get_parent().stats_A[1] += 1
	hide()
	$CollisionShape2D.disabled = true
	queue_free()
