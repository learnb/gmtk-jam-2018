extends RigidBody2D

export (int) var speed

func _ready():
	add_to_group("bullets")

func _process(delta):
	pass
	#position += (velocity*speed) * delta

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func die():
	hide()
	$CollisionShape2D.disabled = true
	queue_free()

func get_pos():
	return position

