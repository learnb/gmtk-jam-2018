extends Area2D

signal gameover

export (PackedScene) var Bullet
export (PackedScene) var MobA
export (PackedScene) var MobB
export (PackedScene) var MobC
export (PackedScene) var MobD

# Game State
var max_health = 3
var health = max_health
var powerup = 0
var screensize
var wave = 0
var checkpoint = 0
var stats_A = [1, 0, 0] # counts: goal, killed, spawned
var stats_B = [0, 0, 0] # counts: goal, killed, spawned
var stats_C = [0, 0, 0] # counts: goal, killed, spawned
var stats_D = [0, 0, 0] # counts: goal, killed, spawned
var gameover = false

# Player State
var gun_length = 25 # Magic number, should be based on Player size
var base_strength = 800
var cooldown = false


func _ready():
	randomize()
	screensize = get_viewport_rect().size
	
	$Player.position = Vector2(screensize.x/2, screensize.y/2)
	#$Player.position = Vector2(100, 100)
	#$Player.position = $StartPosition.position
	$Player/Gun.rotation_degrees = 0
	base_strength = 800
	
	gameover = false
	$TrainTimer.start()
	$PowerUpSpawnTimer.start()
	checkpoint = 0
	change_wave(0)
	$Music.play()


func _process(delta):
	# Check for death condition
	if(health < 1):
		health = 0
		emit_signal("gameover")
	
	
	## Update HUD ##
	$HUD/HealthLabel.text = "Health: " + str(health)
	$HUD/WaveLabel.text = "Wave: " + str(wave)
	$HUD/PowerUpLabel.text = "Power-Ups: " + str(powerup)
	
	$Player.push_strength = base_strength + (powerup * 200)
	#print($Player.push_strength)
	
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
			b.speed = $Player.speed
			b.linear_velocity = target_vec * b.speed
			b.position = $Player.position + (target_vec * gun_length)
			cooldown = true
			$FireTimer.start()
	else: # Push
		# Push Bullets
		$Player.push_on()
	
	# Check for wave end condition
	if not gameover and ((stats_A[0]-stats_A[1] == 0) and (stats_B[0]-stats_B[1] == 0) and (stats_C[0]-stats_C[1] == 0)):
		print("wave end")
		change_wave(wave+1)

func start_game():
	gameover = false
	change_wave(checkpoint)

func gameover():
	health = max_health
	$MobSpawnTimer.stop()
	$PowerUpSpawnTimer.stop()
	# Clear mobs & bullets
	get_tree().call_group("bullets", "die")
	get_tree().call_group("mobs", "die")
	get_tree().call_group("powerups", "die")
	powerup = 0
	
	$HUD.set_message("Game Over.\nReturning to last checkpoint.")
	$HUD.show_message()
	$StartTimer.start()

func change_wave(w):
	$MobSpawnTimer.stop()
	$PowerUpSpawnTimer.stop()
	# Clear mobs & bullets
	get_tree().call_group("bullets", "die")
	get_tree().call_group("mobs", "die")
	
	
	# Set Wave Goals
	if(w == 0):
		$HUD.set_message("Wave 0\nShooting Power-Ups increases\n your Push Strength.")
		$MobSpawnTimer.wait_time = 3
		$PowerUpSpawnTimer.wait_time = 1.5
		stats_A = [1, 0, 0] # counts: goal, killed, spawned
		stats_B = [0, 0, 0] # counts: goal, killed, spawned
		stats_C = [0, 0, 0] # counts: goal, killed, spawned
		stats_D = [3, 0, 0] # counts: goal, killed, spawned
	elif(w == 1):
		$HUD.set_message("Wave 1\nShoot to kill enemies.")
		checkpoint = 1
		$MobSpawnTimer.wait_time = 1.5
		$PowerUpSpawnTimer.wait_time = 3
		stats_A = [5, 0, 0] # counts: goal, killed, spawned
		stats_B = [0, 0, 0] # counts: goal, killed, spawned
		stats_C = [0, 0, 0] # counts: goal, killed, spawned
		stats_D = [1, 0, 0] # counts: goal, killed, spawned
	elif(w == 2):
		$HUD.set_message("Wave 2\nStop shooting to push bullets away.")
		$MobSpawnTimer.wait_time = 2
		$PowerUpSpawnTimer.wait_time = 3
		stats_A = [0, 0, 0] # counts: goal, killed, spawned
		stats_B = [6, 0, 0] # counts: goal, killed, spawned
		stats_C = [0, 0, 0] # counts: goal, killed, spawned
		stats_D = [1, 0, 0] # counts: goal, killed, spawned
	elif(w == 3):
		$HUD.set_message("Wave 3\nPushing doesn't affect enemies.")
		$MobSpawnTimer.wait_time = 2
		$PowerUpSpawnTimer.wait_time = 3
		stats_A = [0, 0, 0] # counts: goal, killed, spawned
		stats_B = [0, 0, 0] # counts: goal, killed, spawned
		stats_C = [5, 0, 0] # counts: goal, killed, spawned
		stats_D = [1, 0, 0] # counts: goal, killed, spawned
	elif(w == 4):
		$HUD.set_message("Checkpoint!\nWave 4")
		checkpoint = 4
		$MobSpawnTimer.wait_time = 3
		$PowerUpSpawnTimer.wait_time = 4.5
		stats_A = [8, 0, 0] # counts: goal, killed, spawned
		stats_B = [4, 0, 0] # counts: goal, killed, spawned
		stats_C = [0, 0, 0] # counts: goal, killed, spawned
		stats_D = [1, 0, 0] # counts: goal, killed, spawned
	elif(w == 5):
		$HUD.set_message("Wave 5")
		$MobSpawnTimer.wait_time = 3
		$PowerUpSpawnTimer.wait_time = 4.5
		stats_A = [8, 0, 0] # counts: goal, killed, spawned
		stats_B = [0, 0, 0] # counts: goal, killed, spawned
		stats_C = [4, 0, 0] # counts: goal, killed, spawned
		stats_D = [1, 0, 0] # counts: goal, killed, spawned
	elif(w == 6):
		$HUD.set_message("Wave 6")
		$MobSpawnTimer.wait_time = 3
		$PowerUpSpawnTimer.wait_time = 4.5
		stats_A = [0, 0, 0] # counts: goal, killed, spawned
		stats_B = [5, 0, 0] # counts: goal, killed, spawned
		stats_C = [5, 0, 0] # counts: goal, killed, spawned
		stats_D = [1, 0, 0] # counts: goal, killed, spawned
	elif(w == 7):
		$HUD.set_message("Checkpoint!\nWave 7")
		checkpoint = 7
		$MobSpawnTimer.wait_time = 3
		$PowerUpSpawnTimer.wait_time = 4.5
		stats_A = [5, 0, 0] # counts: goal, killed, spawned
		stats_B = [5, 0, 0] # counts: goal, killed, spawned
		stats_C = [5, 0, 0] # counts: goal, killed, spawned
		stats_D = [1, 0, 0] # counts: goal, killed, spawned
	elif(w == 8):
		$HUD.set_message("Wave 8")
		checkpoint = 7
		$MobSpawnTimer.wait_time = 2
		$PowerUpSpawnTimer.wait_time = 4.5
		stats_A = [10, 0, 0] # counts: goal, killed, spawned
		stats_B = [5, 0, 0] # counts: goal, killed, spawned
		stats_C = [5, 0, 0] # counts: goal, killed, spawned
		stats_D = [1, 0, 0] # counts: goal, killed, spawned
	elif(w == 9):
		$HUD.set_message("Wave 9")
		checkpoint = 7
		$MobSpawnTimer.wait_time = 2
		$PowerUpSpawnTimer.wait_time = 4.5
		stats_A = [6, 0, 0] # counts: goal, killed, spawned
		stats_B = [6, 0, 0] # counts: goal, killed, spawned
		stats_C = [6, 0, 0] # counts: goal, killed, spawned
		stats_D = [2, 0, 0] # counts: goal, killed, spawned
	elif(w == 10):
		$HUD.set_message("Checkpoint!\nFinal Wave!")
		checkpoint = 10
		$MobSpawnTimer.wait_time = 1.5
		$PowerUpSpawnTimer.wait_time = 4.5
		stats_A = [10, 0, 0] # counts: goal, killed, spawned
		stats_B = [10, 0, 0] # counts: goal, killed, spawned
		stats_C = [10, 0, 0] # counts: goal, killed, spawned
		stats_D = [3, 0, 0] # counts: goal, killed, spawned
	elif(w > 10):
		$HUD.set_message("You beat the game!\nThank you for playing!")
		stats_A = [1, 0, 0] # counts: goal, killed, spawned
	
	
	$HUD.show_message()
	$WaveChangeTimer.start()
	
	# Full Heal
	health = max_health
	
	# Change wave
	wave = w
	# Trigger MobSpawner once WaveChangeTimer fires

func _on_WaveChangeTimer_timeout():
	$MobSpawnTimer.start()
	$PowerUpSpawnTimer.start()

func _on_MobSpawnTimer_timeout():
	if wave == 0:
		pass
	elif wave == 1:
		spawn_mob_A("top")
	elif wave == 2:
		spawn_mob_B("left")
		spawn_mob_B("right")
	elif wave == 3:
		spawn_mob_C("bottom")
	elif wave == 4:
		spawn_mob_A("top")
		spawn_mob_A("bottom")
		spawn_mob_A("top")
		spawn_mob_B("left")
		spawn_mob_B("right")
	elif wave == 5:
		spawn_mob_A("left")
		spawn_mob_A("right")
		spawn_mob_C("any")
	elif wave == 6:
		spawn_mob_B("any")
		spawn_mob_C("any")
		spawn_mob_C("any")
	elif wave == 7:
		spawn_mob_A("any")
		spawn_mob_B("any")
		spawn_mob_C("any")
	elif wave == 8:
		spawn_mob_A("any")
		spawn_mob_B("any")
		spawn_mob_C("any")
		
	elif wave == 9:
		spawn_mob_A("left")
		spawn_mob_B("any")
		spawn_mob_C("top")
		spawn_mob_A("right")
		spawn_mob_B("any")
		spawn_mob_C("bottom")
	elif wave == 10:
		spawn_mob_A("any")
		spawn_mob_B("any")
		spawn_mob_C("any")
		spawn_mob_A("any")
		spawn_mob_B("any")
		spawn_mob_C("any")
	elif wave > 10: # No Spawn (End)
		pass

func _on_PowerUpSpawnTimer_timeout():
	spawn_mob_D("any")

# Move only Mob
func spawn_mob_A(pos):
	# A
	if stats_A[2] < stats_A[0]: # If more to spawn
		stats_A[2] += 1
		var mob = MobA.instance()
		add_child(mob)
		
		if pos == "any":
			var v = randi()%4+1
			if v == 1:
				pos = "left"
			elif v == 2:
				pos = "right"
			elif v == 3:
				pos = "top"
			elif v == 4:
				pos = "bottom"
		if pos == "left":
			mob.position = Vector2(rand_range(0, screensize.x/3), rand_range(0, screensize.y))
		elif pos == "right":
			mob.position = Vector2(rand_range(2*(screensize.x/3), screensize.x), rand_range(0, screensize.y))
		elif pos =="top":
			mob.position = Vector2(rand_range(0, screensize.x), rand_range(0, screensize.y/3))
		elif pos == "bottom":
			mob.position = Vector2(rand_range(0, screensize.x), rand_range(2*(screensize.y/3), screensize.y))
		
		mob.position = Vector2(rand_range(0, screensize.x), rand_range(0, screensize.y/4))
		var target_vec = $Player.position - mob.position # vec pointing at Player
		target_vec = target_vec.normalized()
		mob.velocity = target_vec

# Shoot only Mob
func spawn_mob_B(pos):
	# B
	if stats_B[2] < stats_B[0]: # If more to spawn
		stats_B[2] += 1
		var mob = MobB.instance()
		add_child(mob)
		
		if pos == "any":
			var v = randi()%4+1
			if v == 1:
				pos = "left"
			elif v == 2:
				pos = "right"
			elif v == 3:
				pos = "top"
			elif v == 4:
				pos = "bottom"
		if pos == "left":
			mob.position = Vector2(rand_range(0, screensize.x/3), rand_range(0, screensize.y))
		elif pos == "right":
			mob.position = Vector2(rand_range(2*(screensize.x/3), screensize.x), rand_range(0, screensize.y))
		elif pos =="top":
			mob.position = Vector2(rand_range(0, screensize.x), rand_range(0, screensize.y/3))
		elif pos == "bottom":
			mob.position = Vector2(rand_range(0, screensize.x), rand_range(2*(screensize.y/3), screensize.y))
		
		var target_vec = $Player.position - mob.position # vec pointing at Player
		target_vec = target_vec.normalized()
		mob.velocity = target_vec

# Shoot & Move Mob
func spawn_mob_C(pos):
	# C
	if stats_C[2] < stats_C[0]: # If more to spawn
		stats_C[2] += 1
		var mob = MobC.instance()
		add_child(mob)
		
		if pos == "any":
			var v = randi()%4+1
			if v == 1:
				pos = "left"
			elif v == 2:
				pos = "right"
			elif v == 3:
				pos = "top"
			elif v == 4:
				pos = "bottom"
		if pos == "left":
			mob.position = Vector2(rand_range(0, screensize.x/3), rand_range(0, screensize.y))
		elif pos == "right":
			mob.position = Vector2(rand_range(2*(screensize.x/3), screensize.x), rand_range(0, screensize.y))
		elif pos =="top":
			mob.position = Vector2(rand_range(0, screensize.x), rand_range(0, screensize.y/3))
		elif pos == "bottom":
			mob.position = Vector2(rand_range(0, screensize.x), rand_range(2*(screensize.y/3), screensize.y))
		
		var target_vec = $Player.position - mob.position # vec pointing at Player
		target_vec = target_vec.normalized()
		mob.velocity = target_vec

# Idle Mob (PowerUp)
func spawn_mob_D(pos):
	# C
	if stats_D[2] < stats_D[0]: # If more to spawn
		stats_D[2] += 1
		var mob = MobD.instance()
		add_child(mob)
		
		if pos == "any":
			var v = randi()%4+1
			if v == 1:
				pos = "left"
			elif v == 2:
				pos = "right"
			elif v == 3:
				pos = "top"
			elif v == 4:
				pos = "bottom"
		
		if pos == "left":
			mob.position = Vector2(rand_range(0, screensize.x/3), rand_range(0, screensize.y))
		elif pos == "right":
			mob.position = Vector2(rand_range(2*(screensize.x/3), screensize.x), rand_range(0, screensize.y))
		elif pos =="top":
			mob.position = Vector2(rand_range(0, screensize.x), rand_range(0, screensize.y/3))
		elif pos == "bottom":
			mob.position = Vector2(rand_range(0, screensize.x), rand_range(2*(screensize.y/3), screensize.y))

func _on_TrainTimer_timeout():
	checkpoint = 1
	$StartTimer.start()

func _on_StartTimer_timeout():
	start_game()

func _on_FireTimer_timeout():
	cooldown = false

## Bullet hit Player
func _on_Player_body_entered(body):
	#print("player hit by bullet")
	body.die()
	on_Player_damage()

## Mob hit Player
func _on_Player_area_entered(area):
	if(area.is_in_group("mobs")):
		#print("player hit by mob")
		area.die()
		on_Player_damage()

func on_Player_damage():
	health -= 1
	#print(health)

func _on_ArenaB_gameover():
	gameover = true
	gameover()
