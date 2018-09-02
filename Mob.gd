extends Area2D

signal hit

export (int) var speed
var velocity = Vector2()

func _ready():
	velocity = Vector2(1,1).normalized()
	add_to_group("mobs")

func _process(delta):
	position += (velocity*speed) * delta


func _on_Mob_body_entered(body):
	#print("mob hit detect")
	body.die()
	die()

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

#func die():
#	hide()
#	$CollisionShape2D.disabled = true
#	queue_free()
