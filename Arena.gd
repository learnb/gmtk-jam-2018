extends Area2D

export (PackedScene) var Bullet
export (PackedScene) var MobA
export (PackedScene) var MobB
export (PackedScene) var MobC

var health = 10
var screensize
var gun_length = 25 # Magic number, should be based on Player size

var cooldown = false

func _ready():
	randomize()
	screensize = get_viewport_rect().size
	
	$Player.position = Vector2(screensize.x/2, screensize.y/2)
	#$Player.position = Vector2(100, 100)
	#$Player.position = $StartPosition.position
	$Player/Gun.rotation_degrees = 0
	
	$MobSpawnTimer.start()
	$StartTimer.start()


func _process(delta):
	## User Input ##
	var mouse_pos = get_viewport().get_mouse_position()
	var target_vec = mouse_pos - $Player.position # vec pointing at target
	target_vec = target_vec.normalized()
	
	# get angle
	var target_rad = atan2(target_vec.y, target_vec.x)
	
	# Point gun at target
	$Player/Gun.rotation = target_rad
	$Player/Push.rotation = target_rad
	
	# Fire/Push at target
	if Input.is_action_pressed("ui_action"):
		# Fire Bullet
		if(not cooldown):
			$Player.push_off()
			var b = Bullet.instance()
			add_child(b)
			b.speed /= 2
			b.linear_velocity = target_vec * b.speed
			b.position = $Player.position + (target_vec * gun_length)
			cooldown = true
			$FireTimer.start()
	else: # Push
		# Push Bullets
		$Player.push_on()
		pass
	
	## Spawn Objects ##
	# Mobs
	
	
	# Power-Ups
	
	
func _on_MobSpawnTimer_timeout():
	# A
	var mob = MobA.instance()
	add_child(mob)
	mob.position = Vector2(rand_range(0, screensize.x), rand_range(0, screensize.y/4))
	var target_vec = $Player.position - mob.position # vec pointing at Player
	target_vec = target_vec.normalized()
	mob.velocity = target_vec
	
	# B
	mob = MobB.instance()
	add_child(mob)
	mob.position = Vector2(rand_range(0, screensize.x), rand_range(0, (screensize.y/4)+screensize.y/2))
	target_vec = $Player.position - mob.position # vec pointing at Player
	target_vec = target_vec.normalized()
	mob.velocity = target_vec
	
	# C
	mob = MobC.instance()
	add_child(mob)
	mob.position = Vector2(rand_range(0, screensize.x/4), rand_range(0, screensize.y))
	target_vec = $Player.position - mob.position # vec pointing at Player
	target_vec = target_vec.normalized()
	mob.velocity = target_vec

func _on_StartTimer_timeout():
	var b = Bullet.instance()
	add_child(b)
	b.position = Vector2(rand_range(0, screensize.x), rand_range(0, screensize.y/4))
	var target_vec = $Player.position - b.position # vec pointing at Player
	target_vec = target_vec.normalized()
	b.linear_velocity = target_vec * b.speed



func _on_FireTimer_timeout():
	cooldown = false

## Bullet hit Player
func _on_Player_body_entered(body):
	#print("player hit by bullet")
	body.die()
	on_Player_damage()
	# TODO: lose health

## Mob hit Player
func _on_Player_area_entered(area):
	if(area.is_in_group("mobs")):
		#print("player hit by mob")
		area.die()
		on_Player_damage()

func on_Player_damage():
	health -= 1
	print(health)
