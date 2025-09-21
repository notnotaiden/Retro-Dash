extends Node2D

# Referencing Scene Nodes
@onready var camera: Camera2D = $Camera
@onready var player: CharacterBody2D = $Gameplay/Player
@onready var attempts_text: Label = $Gameplay/AttemptsTxt
@onready var death_ui: Control = $UI/DeathUI
@onready var ceiling_sprite: Sprite2D = $ParallaxCeiling/Ceiling
@onready var songplayer: AudioStreamPlayer = $SongPlayer

var camera_follow: bool = false

# General Functions
func _ready():
	# Connecting signals
	# Death UI restart button pressed
	death_ui.restart_button.connect("pressed", on_player_restart)
	
	# Check state on runtime
	camera_check_state()
	# Load song
	load_song(GameProperties.level_data)
	
	# Update attempts text
	attempts_text.text = "Attempt %d" % [GameProperties.attempts]

func _process(_delta):
	# Camera follow
	camera_move()
	if GameProperties.attempts == 1:
		camera_check_state()
	
	# Increment whenever the player JUST jumped
	if Input.is_action_just_pressed("Player Jump"):
		if death_ui.visible == false: # Only increment when the player is still alive
			GameProperties.jumps += 1
	
	# Move the ceiling ONLY when the player is a cube
	var offset: float = 800.0
	match player.gamemode:
		1: # Cube
			ceiling_sprite.position.y = player.position.y - offset
			ceiling_sprite.modulate.a = 0.0 # NO opacity when cube
		2:
			# Make the ceiling transition to being visible
			ceiling_sprite.modulate.a = lerp(ceiling_sprite.modulate.a, 1.0, 0.1) # NO opacity

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
	if not camera_follow:
		return
	
	camera.position.x = player.position.x + 250 # Offset
	
	var target_y: float
	match player.gamemode:
		1: # Cube
			# Vertical follow
			target_y = player.position.y - 100
		2: # Shib
			# Vertical follow
			target_y = ( player.position.y / 3.0 ) + 80
	
	# Smooth transition
	camera.position.y = lerp(camera.position.y, target_y, 0.05)

# End of System

# Death Mechanic
## Death Mechanic:
## Shows death screen after the player collides with a spike/hazard
## (Signal Function)
func on_player_death():
	# Stop song
	songplayer.stop()
	
	# Update death screen properties
	death_ui.visible = true
	death_ui.update(GameProperties.attempts, GameProperties.jumps)
	
	# Smoothly Animate death screen
	death_ui.position.y = get_viewport().size.y / 2.0
	
	var tween = get_tree().create_tween()
	tween.tween_property(death_ui, "position:y", 0.0, 2.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

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
