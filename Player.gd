extends Area2D

signal hit

export (int) var push_strength
export (int) var speed
var screensize


func _ready():
	add_to_group("player")
	screensize = get_viewport_rect().size
	position = Vector2(300, 300)
	
	$Push.hide()

func _process(delta):
	pass

func push_off():
	$Push.hide()
	$Push/CollisionShape2D.disabled = true

func push_on():
	$Push.show()
	$Push/CollisionShape2D.disabled = false

func _on_Push_body_entered(body):
	#print("push area hit")
	var target_vec = body.position - position # vec pointing at body
	target_vec = target_vec.normalized()
	
	#body.linear_velocity = target_vec * body.speed
	
	body.set_applied_force(target_vec * push_strength)


func _on_Push_body_exited(body):
	body.set_applied_force(Vector2())
