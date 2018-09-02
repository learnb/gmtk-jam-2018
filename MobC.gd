extends "Mob.gd"
# Shoot & Move Mob

export (PackedScene) var Bullet

var dead
var gun_length = 30

func _ready():
	speed = 20
	dead = false
	add_to_group("mobs")
	$FireTimer.start()
	play_spawn_sfx()

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
	if not dead:
		dead = true
		get_parent().stats_C[1] += 1
		hide()
		$CollisionShape2D.disabled = true
		queue_free()
