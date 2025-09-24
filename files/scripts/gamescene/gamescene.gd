extends Node2D

# Referencing Scene Nodes
@onready var camera: Camera2D = $Camera
@onready var player: CharacterBody2D = $Gameplay/Player

# Ui
@onready var attempts_text: Label = $Gameplay/AttemptsTxt
@onready var death_ui: Control = $UI/DeathUI
@onready var progress_bar: ProgressBar = $UI/ProgressBar
@onready var pause_ui: Control = $UI/PauseMenu
@onready var scene_particles: CPUParticles2D = $SceneParticles

# Parallax
@onready var bg_sprite: Sprite2D = $ParallaxBG/BG
@onready var ceiling_sprite: Sprite2D = $ParallaxCeiling/Ceiling
@onready var ground_sprite: Sprite2D = $ParallaxGround/Ground

# Others
@onready var songplayer: AudioStreamPlayer = $SongPlayer
@onready var level_node: Node = $Level

var camera_follow: bool = false

# General Functions
func _ready():
	# Connecting signals
	# Death UI restart button pressed
	death_ui.restart_button.connect("pressed", on_player_restart)
	# Pause UI resturn button pressed
	pause_ui.return_button.connect("pressed", unpaused)
	# Pause UI restart button pressed
	pause_ui.restart_button.connect("pressed", pause_restart)
	
	# Check state on runtime
	camera_check_state()
	# Load song
	load_song(GameProperties.level_data)
	
	# Update attempts text
	attempts_text.text = "Attempt %d" % [GameProperties.attempts]

func _process(delta):
	# Camera follow
	if not player.finished:
		camera_move()
		if GameProperties.attempts == 1:
			camera_check_state()
	
	# Increment whenever the player JUST jumped
	if Input.is_action_just_pressed("Player Jump"):
		if death_ui.visible == false: # Only increment when the player is still alive
			GameProperties.jumps += 1
	
	# Gamemode boundaries system
	gamemode_boundary(player.gamemode)
	
	# Changes the color for both the background and ground
	# Checks if the ground and bg hasn't reached the desired color yet
	if not player.dead:
		if ground_sprite.modulate != player.color_trigger.ground_color or bg_sprite.modulate != player.color_trigger.bg_color:
			color_change(player.color_trigger, delta)
	
	# Progress Bar
	if not player.dead:
		update_progress_bar()
	
	# Pause System
	if Input.is_key_pressed(KEY_ESCAPE):
		if not player.dead:
			get_tree().paused = true
			paused()
	
	# Scene Particles System
	scene_particles.position = player.position + Vector2(get_viewport().size.x / 2.0, 0)
	if player.gamemode == 1:
		scene_particles.visible = false
		scene_particles.emitting = false
	else:
		scene_particles.visible = true
		scene_particles.emitting = true

# Pause System
## Pause System:
## Moves the pause screen after being paused
## (Main Function)
func paused():
	pause_ui.visible = true
	
	# Smoothly Animate pause screen
	pause_ui.position.y = get_viewport().size.y
	
	# Add tween animation to death screen
	var tween = pause_ui.create_tween()
	tween.tween_property(pause_ui, "position:y", 0.0, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

# Pause System
## Pause System:
## Moves the pause screen after being paused (Button Version)
## (Signal Function)
func pausebtn_pressed():
	if not player.dead:
		get_tree().paused = true
		paused()

## Pause System:
## Moves the pause screen off screen after being unpaused
## (Signal Function)
func unpaused():
	pause_ui.return_button.release_focus()
	
	# Unpause scene
	get_tree().paused = false
	
	# Smoothly Animate pause screen back to off screen
	var pos_y = get_viewport().size.y
	
	# Add tween animation to death screen
	var tween = pause_ui.create_tween()
	tween.tween_property(pause_ui, "position:y", pos_y, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

## Pause System:
## Restarts entire scene
## (Signal Function)
func pause_restart():
	# Increment attempts
	GameProperties.attempts += 1
	# Restart Jumps
	GameProperties.jumps = 0
	
	# unpause scene first
	get_tree().paused = false
	
	# Reload entire scene
	get_tree().reload_current_scene()

# End of System

# Progress Bar Ssytem
## Progress Bar System:
## Displays the amount of time the user has in a level
## (Main Function)
func update_progress_bar():
	if songplayer.stream and songplayer.playing:
		var song_length: float = songplayer.stream.get_length()
		var current_time: float = songplayer.get_playback_position()
		
		if song_length > 0.0:
			# Turn into 0-100 percentage
			var progress: float = (current_time / song_length) * 100.0
			progress_bar.value = progress

# Color System
## Color System:
## Changes the BG and Ground tint color
## (Signal Function)
func color_change(color_trigger, delta):
	var bg_color: Color = color_trigger.bg_color
	var ground_color: Color = color_trigger.ground_color
	
	# Turn seconds into a usable weight for lerp() to use
	var bg_change_time: float = color_trigger.bg_change_time
	var bg_change_weight: float = clamp(delta / bg_change_time, 0.0, 1.0)
	
	var ground_change_time: float = color_trigger.ground_change_time
	var ground_change_weight: float = clamp(delta / ground_change_time, 0.0, 1.0)
	
	# Transition BG and Ground tint color to new color
	if bg_change_weight > 0.0:
		# Slowly transition onto it
		bg_sprite.modulate = lerp(bg_sprite.modulate, bg_color, bg_change_weight)
	else:
		# Immediently apply it
		bg_sprite.modulate = bg_color
	
	if ground_change_weight > 0.0:
		# Slowly transition onto it
		ground_sprite.modulate = lerp(ground_sprite.modulate, ground_color, ground_change_weight)
		ceiling_sprite.modulate = lerp(ceiling_sprite.modulate, ground_color, ground_change_weight)
	else:
		# Immediently apply it
		ground_sprite.modulate = ground_color
		ceiling_sprite.modulate = ground_color

# End

# Gamemode Boundary system
## Gamemode Boundary System:
## Finds the exact boundary for each gamemodes
## (Main Function)
func gamemode_boundary(gamemode):
	var ceiling_pos_y: float
	var ground_pos_y: float
	
	match gamemode:
		1: # Cube
			# Make both the ceiling and ground go back
			ground_pos_y = GameProperties.MAX_GROUND_YPOS
			ceiling_pos_y = -5000.0
		2: # Ship
			
			# Clamp the ground first so it doesn't go past the max floor level
			var boundary_height: float = GameProperties.SHIP_BOUNDARY_HEIGHT / 2.0
			ground_pos_y = min(player.gamemode_portal.position.y + boundary_height, GameProperties.MAX_GROUND_YPOS)
			# Ceiling is just boundary_height above the ground
			ceiling_pos_y = ground_pos_y - GameProperties.SHIP_BOUNDARY_HEIGHT
		3: # Ball
			
			# Clamp the ground first so it doesn't go past the max floor level
			var boundary_height: float = GameProperties.BALL_BOUNDARY_HEIGHT / 2.0
			ground_pos_y = min(player.gamemode_portal.position.y + boundary_height, GameProperties.MAX_GROUND_YPOS)
			# Ceiling is just boundary_height above the ground
			ceiling_pos_y = ground_pos_y - GameProperties.BALL_BOUNDARY_HEIGHT
	
	# Make both the ceiling and ground transition smoothly (Since the ceiling is higher, make it go faster)
	ceiling_sprite.position.y = lerp(ceiling_sprite.position.y, ceiling_pos_y, 0.15)
	ground_sprite.position.y = lerp(ground_sprite.position.y, ground_pos_y, 0.15)

# End of System

# Load Song Mechanic
## Load Song Mechanic:
## Loads the mp3 file provided in the data provided
## (Main Function)
func load_song(data: Dictionary):
	if not FileAccess.file_exists(data["SongPath"]):
		return
	
	# Create new mp3 stream
	var mp3_stream = AudioStreamMP3.new()
	# Access file
	var file = FileAccess.open(data["SongPath"], FileAccess.READ)
	
	# Get mp3 data
	mp3_stream.data = file.get_buffer(file.get_length())
	if mp3_stream.data.is_empty():
		return
	
	# Update songplayer stream
	songplayer.stream = mp3_stream
	songplayer.play()
	file.close()

# Camera Follow Mechanic
## Camera Follow Mechanic:
## Checks if the user is currently on attempt 1, then do a quick transition
## (Main Function)
func camera_check_state():
	# When first entering the level, do not immediently make the camera follow the player
	if GameProperties.attempts == 1:
		var viewport_width_half: float = get_viewport().size.x / 2.0
		if player.position.x >= ( viewport_width_half / 1.7 ):
			camera_follow = true
	else:
		camera_follow = true
## Camera Follow Mechanic:
## Moves the camera
## (Main Function)
func camera_move():
	# Return if the camera_follow bool is false
	if not camera_follow:
		return
	
	# Sets the position x of the camera
	camera.position.x = player.position.x + 250 # Offset
	
	# Sets the position y of the camera
	var target_y: float
	match player.gamemode:
		1: # Cube
			# Vertical follow
			target_y = player.position.y - 80
		2: # Ship
			# Vertical follow (Makes the camera centered)
			# Find ceiling and ground position
			
			# Clamp the ground first so it doesn't go past the max floor level
			var boundary_height: float = GameProperties.SHIP_BOUNDARY_HEIGHT / 2.0
			var ground_pos_y = min(player.gamemode_portal.position.y + boundary_height, GameProperties.MAX_GROUND_YPOS)
			# Ceiling is just boundary_height above the ground
			var ceiling_pos_y = ground_pos_y - GameProperties.SHIP_BOUNDARY_HEIGHT
			
			var offset: float = 10.0
			target_y = (ceiling_pos_y + ground_pos_y) / 2.0 - offset
		3: # Ball
			# Vertical follow (Makes the camera centered)
			# Find ceiling and ground position
			
			# Clamp the ground first so it doesn't go past the max floor level
			var boundary_height: float = GameProperties.BALL_BOUNDARY_HEIGHT / 2.0
			var ground_pos_y = min(player.gamemode_portal.position.y + boundary_height, GameProperties.MAX_GROUND_YPOS)
			# Ceiling is just boundary_height above the ground
			var ceiling_pos_y = ground_pos_y - GameProperties.BALL_BOUNDARY_HEIGHT
			
			var offset: float = 0.0
			target_y = (ceiling_pos_y + ground_pos_y) / 2.0 - offset
	
	# Smooth transition to position y
	camera.position.y = lerp(camera.position.y, target_y, 0.05)

# End of System

# Death Mechanic
## Death Mechanic:
## Shows death screen after the player collides with a spike/hazard
## (Signal Function)
func on_player_death():
	# Stop song
	songplayer.stop()
	
	# Camera shake
	if not player.dead:
		camera.apply_shake(9.0)
	
	# Update death screen properties
	death_ui.visible = true
	death_ui.update(GameProperties.attempts, GameProperties.jumps)
	
	# Smoothly Animate death screen
	death_ui.position.y = get_viewport().size.y
	
	# Add tween animation to death screen
	var tween = get_tree().create_tween()
	tween.tween_property(death_ui, "position:y", 0.0, 1.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_delay(0.5)

## Death Mechanic:
## Restarts everything after the player clicks restart
## (Signal Function)
func on_player_restart():
	# Increment attempts
	GameProperties.attempts += 1
	# Restart Jumps
	GameProperties.jumps = 0
	# Restart dead bool
	player.dead = false
	
	# Reload entire scene
	get_tree().reload_current_scene()

# End
