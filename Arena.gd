extends Area2D

export (PackedScene) var Bullet
export (PackedScene) var MobA
export (PackedScene) var MobB
export (PackedScene) var MobC

# Game State
var health = 10
var screensize
var wave = 0
var stats_A = [1, 0, 0] # counts: goal, killed, spawned
var stats_B = [0, 0, 0] # counts: goal, killed, spawned
var stats_C = [0, 0, 0] # counts: goal, killed, spawned


# Player State
var gun_length = 25 # Magic number, should be based on Player size
var cooldown = false


func _ready():
	randomize()
	screensize = get_viewport_rect().size
	
	$Player.position = Vector2(screensize.x/2, screensize.y/2)
	#$Player.position = Vector2(100, 100)
	#$Player.position = $StartPosition.position
	$Player/Gun.rotation_degrees = 0
	
	
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
			b.speed *= 4
			b.linear_velocity = target_vec * b.speed
			b.position = $Player.position + (target_vec * gun_length)
			cooldown = true
			$FireTimer.start()
	else: # Push
		# Push Bullets
		$Player.push_on()
	
	# Check for wave end condition
	if(stats_A[0]-stats_A[1] == 0) and (stats_B[0]-stats_B[1] == 0) and (stats_C[0]-stats_C[1] == 0):
		print("wave end")
		change_wave(wave+1)

func start_game():
	change_wave(1)

func change_wave(w):
	$MobSpawnTimer.stop()
	# Clear mobs & bullets
	get_tree().call_group("bullets", "die")
	get_tree().call_group("mobs", "die")
	
	# Full Heal
	health = 10
	
	# Set Wave Goals
	if(w == 0):
		$MobSpawnTimer.wait_time = 3
		stats_A = [5, 0, 0] # counts: goal, killed, spawned
		stats_B = [5, 0, 0] # counts: goal, killed, spawned
		stats_C = [5, 0, 0] # counts: goal, killed, spawned
	elif(w == 1):
		$MobSpawnTimer.wait_time = 1.5
		stats_A = [5, 0, 0] # counts: goal, killed, spawned
		stats_B = [0, 0, 0] # counts: goal, killed, spawned
		stats_C = [0, 0, 0] # counts: goal, killed, spawned
	elif(w == 2):
		$MobSpawnTimer.wait_time = 3
		stats_A = [0, 0, 0] # counts: goal, killed, spawned
		stats_B = [6, 0, 0] # counts: goal, killed, spawned
		stats_C = [0, 0, 0] # counts: goal, killed, spawned
	elif(w == 3):
		$MobSpawnTimer.wait_time = 2
		stats_A = [0, 0, 0] # counts: goal, killed, spawned
		stats_B = [0, 0, 0] # counts: goal, killed, spawned
		stats_C = [5, 0, 0] # counts: goal, killed, spawned
	
	# Change wave
	wave = w
	$MobSpawnTimer.start()

func _on_MobSpawnTimer_timeout():
	if wave == 0:
		spawn_mob_A()
		spawn_mob_B()
		spawn_mob_C()
	elif wave == 1:
		spawn_mob_A()
	elif wave == 2:
		spawn_mob_B()
		spawn_mob_B()
		spawn_mob_B()
	elif wave == 3:
		spawn_mob_C()

# Move only Mob
func spawn_mob_A():
	# A
	if stats_A[2] < stats_A[0]: # If more to spawn
		stats_A[2] += 1
		var mob = MobA.instance()
		add_child(mob)
		mob.position = Vector2(rand_range(0, screensize.x), rand_range(0, screensize.y/4))
		var target_vec = $Player.position - mob.position # vec pointing at Player
		target_vec = target_vec.normalized()
		mob.velocity = target_vec

# Shoot only Mob
func spawn_mob_B():
	# B
	if stats_B[2] < stats_B[0]: # If more to spawn
		stats_B[2] += 1
		var mob = MobB.instance()
		add_child(mob)
		mob.position = Vector2(rand_range(0, screensize.x), rand_range(0, (screensize.y/4)+screensize.y/2))
		var target_vec = $Player.position - mob.position # vec pointing at Player
		target_vec = target_vec.normalized()
		mob.velocity = target_vec

# Shoot & Move Mob
func spawn_mob_C():
	# C
	if stats_C[2] < stats_C[0]: # If more to spawn
		stats_C[2] += 1
		var mob = MobC.instance()
		add_child(mob)
		mob.position = Vector2(rand_range(0, screensize.x/4), rand_range(0, screensize.y))
		var target_vec = $Player.position - mob.position # vec pointing at Player
		target_vec = target_vec.normalized()
		mob.velocity = target_vec

func _on_StartTimer_timeout():
	start_game()

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


