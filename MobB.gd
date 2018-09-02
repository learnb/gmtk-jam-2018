extends "Mob.gd"
# Shoot only Mob

export (PackedScene) var Bullet

var gun_length = 45

func _ready():
	speed = 0
	scale = Vector2(.75, .75)
	$FireTimer.start()
	pass

func _process(delta):
	pass


func _on_FireTimer_timeout():
	var b = Bullet.instance()
	get_parent().add_child(b)
	#var target_vec = $Player.position - b.position # vec pointing at Player
	var target_vec = get_parent().get_node("Player").position - position # vec pointing at Player
	target_vec = target_vec.normalized()
	b.position = position + (target_vec * gun_length)
	b.linear_velocity = target_vec * b.speed

func die():
	get_parent().stats_B[1] += 1
	hide()
	$CollisionShape2D.disabled = true
	queue_free()
