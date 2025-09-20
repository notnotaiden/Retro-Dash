extends Node2D

# Referencing Scene Nodes
@onready var camera: Camera2D = $Camera
@onready var player: CharacterBody2D = $Gameplay/Player
@onready var attempts_text: Label = $Gameplay/AttemptsTxt
@onready var death_ui: Control = $UI/DeathUI

var camera_follow: bool = false

# General Functions
func _ready():
	# Connecting signals
	# Death UI restart button pressed
	death_ui.restart_button.connect("pressed", on_player_restart)
	
	# Check state on runtime
	camera_check_state()
	
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
	if camera_follow:
		camera.position.x = player.position.x + 250 # Offset
		
		# Follow the player y position ONLY if the player has reached a certain y position (Near Y 0)
		if player.position.y <= 200.0:
			camera.position.y = player.position.y

# End of System


# Death Mechanic
## Death Mechanic:
## Shows death screen after the player collides with a spike/hazard
## (Signal Function)
func on_player_death():
	death_ui.visible = true
	death_ui.update(GameProperties.attempts, GameProperties.jumps)

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
