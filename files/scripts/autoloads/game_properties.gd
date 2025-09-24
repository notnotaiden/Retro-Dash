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

# Holds the amount of attempts and jumps you currently have on this playthrough
var attempts: int = 1
var jumps: int = 0

# Holds the level data of the current level
var level_path: String = "res://files/levels/level1"
var level_data: Dictionary = {}

# General Functions
func _ready():
	load_level_data()

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
