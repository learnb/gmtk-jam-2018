extends "Mob.gd"

export (PackedScene) var Bullet

func _ready():
	speed /= 2
	$FireTimer.start()
	pass

func _process(delta):
	pass


func _on_FireTimer_timeout():
	var b = Bullet.instance()
	add_child(b)
	b.position = position
	#var target_vec = $Player.position - b.position # vec pointing at Player
	var target_vec = get_tree().get_group("player")[0].position -b.position # vec pointing at Player
	target_vec = target_vec.normalized()
	b.linear_velocity = target_vec * b.speed
