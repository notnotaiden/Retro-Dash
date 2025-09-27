extends Node

# Game Properties
## Holds the user choosen settings
var user_settings: Dictionary = {
	"settings": {
		"sound_vol": 1.0,
		"music_vol": 1.0
	},
	"customization": {
		"p1_color": Color.YELLOW,
		"p2_color": Color.DEEP_SKY_BLUE,
		"cube_skin": {
			"outline": Rect2(0.0, 0.0, 32.0, 32.0),
			"p1": Rect2(32.0, 0.0, 32.0, 32.0),
			"p2": Rect2(64.0, 0.0, 32.0, 32.0)
		},
		"ship_skin": {
			"outline": Rect2(96.0, 0.0, 32.0, 32.0),
			"p1": Rect2(0.0, 32.0, 32.0, 32.0),
			"p2": Rect2(32.0, 32.0, 32.0, 32.0)
		},
		"ball_skin": {
			"outline": Rect2(64.0, 32.0, 32.0, 32.0),
			"p1": Rect2(96.0, 32.0, 32.0, 32.0),
			"p2": Rect2(0.0, 64.0, 32.0, 32.0)
		}
	},
}

## The position the player starts with in every attempt
const START_POS: Vector2 = Vector2(-64.0, 499.0)
## The max y position the ground can go
const MAX_GROUND_YPOS: float = 665.0
# Gamemode boundaries offset
const SHIP_BOUNDARY_HEIGHT: float = 860.0
const BALL_BOUNDARY_HEIGHT: float = 820.0

# Player properties
# Different jump heights of different gamemodes
const CUBE_JUMPHEIGHT: float = -1270.0
const SHIP_JUMPHEIGHT: float = -3450.0
# Different gravities for different gamemodes
const CUBE_GRAVITY: float = 5000.0
const SHIP_GRAVITY: float = 1500.0
const BALL_GRAVITY: float = 3800.0

# Different orb jump heights and pad jump heights for different gamemodes
const ORB_CUBE_JUMPHEIGHT: float = -1270.0
const ORB_SHIP_JUMPHEIGHT: float = -550.0
const ORB_BALL_JUMPHEIGHT: float = -850.0

const PAD_CUBE_JUMPHEIGHT: float = -1714.5
const PAD_SHIP_JUMPHEIGHT: float = -850.0
const PAD_BALL_JUMPHEIGHT: float = -1450.0

## The rotational speed for the ship gamemode
const SHIP_ROTATIONAL_SPEED: float = 6.0
## The max angle the player can go upward for the ship gamemode
const SHIP_MAXANGLE_UP: float = -70.0
## The max angle the player can go downward for the ship gamemode
const SHIP_MAXANGLE_DOWN: float = 60.0
## The max y velocity the player could go for the ship gamemode
const SHIP_MAXVELO_y: float = 1000.0

# Main Menu Properties
const camera_speed_menu: float = 500.0

# Holds the amount of attempts and jumps you currently have on this playthrough
var attempts: int = 1
var jumps: int = 0

# Animations
var orb_scale: float = 3.0

## Holds the state to check if the player is currently playing a level
var playing: bool = false
var practice_mode: bool = false
var practice_music_player: AudioStreamPlayer = AudioStreamPlayer.new()
## Holds an array of checkpoints nodes placed on the scene
var placed_checkpoints: Array = []

# Holds the level data of the current level
var level_path: String = "res://files/levels/level1" # Just change the path to the level folder
var level_data: Dictionary = {}

# General Functions
func _ready():
	add_child(practice_music_player)
	# Update practice music player stream
	practice_music_player.stream = load("res://files/assets/music/practice.mp3")

func _process(_delta):
	if practice_mode:
		play_practice_song()
	else:
		practice_music_player.stop()
	
	# Full screen mechanic
	if Input.is_key_pressed(KEY_F11):
		var window = get_window()
		if window.mode == Window.MODE_FULLSCREEN:
			window.mode = Window.MODE_WINDOWED
		else:
			window.mode = Window.MODE_FULLSCREEN

# Level Load System
## Level Load System:
## Loads the json file of the corresponding level selected
## (Main Function)
func load_level_data():
	# Find json file path
	var json_file = level_path.path_join("level.json")
	
	var file = FileAccess.open(json_file, FileAccess.READ)
	var json_text = file.get_as_text()
	level_data = JSON.parse_string(json_text)

# End

# Practice Mode Music
## Practice Mode Music:
## Plays the practice mode music when practice mode is turned on
## (Main Function)
func play_practice_song():
	practice_music_player.volume_linear = user_settings["settings"]["music_vol"]
	
	if practice_mode:
		if not practice_music_player.playing:
			practice_music_player.play()
	else:
		practice_music_player.stop()
