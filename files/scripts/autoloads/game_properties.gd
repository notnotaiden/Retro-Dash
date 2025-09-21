extends Node

# Game Properties
## The position the player starts with in every attempt
const START_POS: Vector2 = Vector2(-64.0, 499.0)
# Different jump heights of different gamemodes
const CUBE_JUMPHEIGHT: float = -1230.0
const SHIP_JUMPHEIGHT: float = -3050.0

# Holds the level data
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
