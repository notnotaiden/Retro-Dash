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
@onready var place_checkpoint_btn: Button  = $UI/PlaceCheckpoint
@onready var delete_checkpoint_btn: Button = $UI/DeleteCheckpoint
@onready var fade_out: ColorRect = $UI/FadeOutFinish
@onready var complete_text: Label = $UI/CompleteText
@onready var complete_ui: Control = $UI/CompleteScreen

# Parallax
@onready var bg_sprite: Sprite2D = $ParallaxBG/BG
@onready var ceiling_sprite: Sprite2D = $ParallaxCeiling/Ceiling
@onready var ground_sprite: Sprite2D = $ParallaxGround/Ground
@onready var ground_sprite2: Sprite2D = $ParallaxGround2/Ground

# Others
@onready var songplayer: AudioStreamPlayer = $SongPlayer
@onready var level_node: Node = $Level
@onready var level_blocks_node: Node
@onready var checkpoints_node: Node = $Checkpoints
@onready var practice_timer: Timer = $PracticeModeDelayReset
@onready var sound_player: AudioStreamPlayer = $SoundPlayer

var camera_follow: bool = false
## Holds the state if the player is not touching a ui node
var on_ui: bool = false

## Checkpoint node
var CHECKPOINT_FILE: PackedScene = preload("res://files/objects/checkpoint.tscn")

# General Functions
func _ready():
	GameProperties.playing = true
	GameProperties.load_level_data()
	
	# Adding level to the scene
	load_level()
	
	# Connecting signals
	# Death UI restart button pressed
	death_ui.restart_button.connect("pressed", on_player_restart)
	# Pause UI resturn button pressed
	pause_ui.return_button.connect("pressed", unpaused)
	# Pause UI practice button pressed
	pause_ui.practice_button.connect("pressed", pause_practice)
	# Complete UI restart button
	complete_ui.restart_button.connect("pressed", on_complete_restart)
	
	# Update ground, ceiling, and bg color
	ground_sprite.modulate = Color.ROYAL_BLUE
	ground_sprite2.modulate = Color.ROYAL_BLUE
	ceiling_sprite.modulate = Color.ROYAL_BLUE
	bg_sprite.modulate = Color.ROYAL_BLUE
	
	# Check state on runtime
	camera_check_state()
	# Load song
	load_song(GameProperties.level_data)
	
	# Practice mode
	if GameProperties.practice_mode:
		place_checkpoint_btn.visible = true
		delete_checkpoint_btn.visible = true
		
		if GameProperties.placed_checkpoints.size() > 0.0:
			# Update camera position
			
			# Retrieves the last camera position
			var checkpoint = GameProperties.placed_checkpoints[ GameProperties.placed_checkpoints.size() - 1]
			camera.position = checkpoint["camera_pos"]
			
			# Recreating checkpoint nodes
			recreate_checkpoints()
	else:
		place_checkpoint_btn.visible = false
		delete_checkpoint_btn.visible = false
	
	# Update attempts text
	attempts_text.text = "Attempt %d" % [GameProperties.attempts]

func _process(delta):
	# Camera follow
	if not player.finished and not player.dead:
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
		if not player.dead or not player.finished:
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
	
	if GameProperties.practice_mode:
		# Don't completely stop the music but js lower down the volume for the progress bar system
		songplayer.volume_linear = 0.0
	
	# Finish mechanic
	if progress_bar.value >= 99:
		fade_out.color.a = lerp(fade_out.color.a, 1.0, 0.05)
		
		if not player.finished:
			player.finished = true
			sound_player.play()
			sound_player.volume_linear = GameProperties.user_settings["settings"]["sound_vol"]
			
			# Update complete screen properties
			complete_ui.update(GameProperties.attempts, GameProperties.jumps)
			
			# Animation
			var complete_text_tween_scale = get_tree().create_tween()
			complete_text_tween_scale.tween_property(complete_text, "scale", Vector2(1.0, 1.0), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_delay(3.5)
			var complete_text_tween_alpha = get_tree().create_tween()
			complete_text_tween_alpha.tween_property(complete_text, "modulate:a", 0.0, 1.0).set_ease(Tween.EASE_OUT).set_delay(4.5)
			var complete_ui_tween = get_tree().create_tween()
			complete_ui_tween.tween_property(complete_ui, "position:y", 0.0, 2.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE).set_delay(5.0)


func _input(event):
	if event is InputEventKey:
		if event.is_pressed() and not event.is_echo():
			# Checkpoint System
			if GameProperties.practice_mode:
				if event.keycode == KEY_Z:
					place_checkpoint()
				if event.keycode == KEY_X:
					delete_checkpoint()

# Checkpoint System
## Checkpoint System:
## Places a checkpoint node
## (Main Function)
func place_checkpoint():
	# Add checkpoint to scene
	var new_checkpoint = CHECKPOINT_FILE.instantiate()
	checkpoints_node.add_child(new_checkpoint)
	
	# Update checkpoint data
	new_checkpoint.data["position"] = player.global_position
	new_checkpoint.data["camera_pos"] = camera.global_position
	new_checkpoint.data["velocity"] = player.velocity
	new_checkpoint.data["song_playback"] = songplayer.get_playback_position()
	new_checkpoint.data["gravity"] = player.GRAVITY
	new_checkpoint.data["gamemode"] = player.gamemode
	
	var checkpoint_data: Dictionary = {
		"position": player.global_position,
		"camera_pos": camera.global_position,
		"velocity": player.velocity,
		"song_playback": songplayer.get_playback_position(),
		"gravity": player.GRAVITY,
		"gamemode": player.gamemode
	}
	
	# Update checkpoint position
	new_checkpoint.global_position = player.global_position
	
	# Update checkpoints array
	GameProperties.placed_checkpoints.append(checkpoint_data)
	
	# Unfocus button
	place_checkpoint_btn.release_focus()

## Checkpoint System:
## Deletes the recently created checkpoint node
## (Main Function)
func delete_checkpoint():
	# Removes last placed checkpoint
	var last_checkpoint = GameProperties.placed_checkpoints.pop_back()
	
	# Loop through every checkpoints node and if it matches the position in the data, delete it
	for checkpoint in checkpoints_node.get_children():
		if checkpoint.data["position"] == last_checkpoint["position"]:
			checkpoint.queue_free()
			break
	
	# Unfocus button
	delete_checkpoint_btn.release_focus()

# Checkpoint System
## Checkpoint System:
## Recreates the placed checkpoints
## (Main Function)
func recreate_checkpoints():
	# Loops through every placed checkpoints in the array
	for checkpoint in GameProperties.placed_checkpoints:
		var new_checkpoint = CHECKPOINT_FILE.instantiate()
		checkpoints_node.add_child(new_checkpoint)
		
		# Update checkpoint data
		new_checkpoint.data["position"] = checkpoint["position"]
		new_checkpoint.data["camera_pos"] = checkpoint["camera_pos"]
		new_checkpoint.data["velocity"] = checkpoint["velocity"]
		new_checkpoint.data["song_playback"] = checkpoint["song_playback"]
		new_checkpoint.data["gravity"] = checkpoint["gravity"]
		new_checkpoint.data["gamemode"] = checkpoint["gamemode"]
		
		new_checkpoint.position = checkpoint["position"]

# End of System

# Loading Level
## Loading Level:
## Adds the respective level to the scene
## (Main Function)
func load_level():
	# Construct path to the scene file
	var level_path: String = GameProperties.level_path.path_join("level.tscn")
	# Instantiate
	var level: PackedScene = load(level_path)
	var new_level = level.instantiate()
	# Add to scene
	level_node.add_child(new_level)
	level_blocks_node = new_level.get_node("Level")

# End of system

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
func pause_practice():
	# Reset attempts
	GameProperties.attempts = 1
	# Restart Jumps
	GameProperties.jumps = 0
	# Update practice mode bool
	GameProperties.practice_mode = !GameProperties.practice_mode
	
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
		ground_sprite2.modulate = lerp(ground_sprite.modulate, ground_color, ground_change_weight)
		ceiling_sprite.modulate = lerp(ceiling_sprite.modulate, ground_color, ground_change_weight)
	else:
		# Immediently apply it
		ground_sprite.modulate = ground_color
		ground_sprite2.modulate = ground_color
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
			if not player.gamemode_portal == null:
				var boundary_height: float = GameProperties.SHIP_BOUNDARY_HEIGHT / 2.0
				ground_pos_y = min(player.gamemode_portal.position.y + boundary_height, GameProperties.MAX_GROUND_YPOS)
				# Ceiling is just boundary_height above the ground
				ceiling_pos_y = ground_pos_y - GameProperties.SHIP_BOUNDARY_HEIGHT
		3: # Ball
			
			if not player.gamemode_portal == null:
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
	songplayer.volume_linear = GameProperties.user_settings["settings"]["music_vol"]
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
			if not player.gamemode_portal == null:
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
			if not player.gamemode_portal == null:
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
	
	if not GameProperties.practice_mode:
		# Add tween animation to death screen
		var tween = get_tree().create_tween()
		tween.tween_property(death_ui, "position:y", 0.0, 1.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_delay(0.5)
	else:
		practice_timer.start(1.0)

## Death Mechanic:
## Restarts everything upon timer finish (Practice mode)
## (Signal Function)
func on_timer_finished():
	if GameProperties.practice_mode:
		if GameProperties.placed_checkpoints.size() > 0:
			if player.dead:
				player.return_by_death()
				
				# Restart dead bool
				player.dead = false
				# Make texture visible again
				player.texture.visible = true
				# Increment attempts
				GameProperties.attempts += 1
				# Update attempts text
				attempts_text.text = "Attempt %d" % [GameProperties.attempts]
				# Restart Jumps
				GameProperties.jumps = 0
				
				if GameProperties.practice_mode:
					if GameProperties.placed_checkpoints.size() > 0.0:
						# Play song again
						# Retrieve the last song playback position
						# Retrieve the last camera position
						var checkpoint = GameProperties.placed_checkpoints[ GameProperties.placed_checkpoints.size() - 1]
						
						songplayer.play(checkpoint["song_playback"])
						camera.position = checkpoint["camera_pos"]
				
				# Restart has_used bool state for every orbs, pads, and portals
				for node in level_blocks_node.get_children():
					if node is Orb or node is Pad or node is Portal or node is Speedportal:
						node.has_used = false
		else:
			# Increment attempts
			GameProperties.attempts += 1
			# Restart Jumps
			GameProperties.jumps = 0
			# Restart dead bool
			player.dead = false
			
			get_tree().reload_current_scene()

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

## Complete Mechanic:
## Restarts everything after the player clicks restart
## (Signal Function)
func on_complete_restart():
	# Restart attempts
	GameProperties.attempts = 1
	# Restart Jumps
	GameProperties.jumps = 0
	# Restart dead bool
	player.dead = false
	
	# Reload entire scene
	get_tree().reload_current_scene()

# End

# On UI
## On UI System
## Checks if the player has touched on a UI element or not (Mouse enter)
## (Signal Function)
func on_ui_mouse_entered():
	on_ui = true

## On UI System
## Checks if the player has touched on a UI element or not (Mouse exit)
## (Signal Function)
func on_ui_mouse_exited():
	on_ui = false

# End of system
