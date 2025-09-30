extends Panel

# Reference scene nodes
@onready var name_txt: Label = $LevelNamePanel/Name
@onready var length_text: Label = $Length
@onready var face: Sprite2D = $DifficultyPanel/Face

@onready var play: Button = $Play
@onready var normal_stats: ProgressBar = $StatsPanel/NormalProgress
@onready var practice_stats: ProgressBar = $StatsPanel/PracticeProgress

## Each level panel has a unique level path that basically holds a string path 
## to their respective level
@export var level_path: String = "res://files/levels/level1"
@export var unlockable: bool = false
@export var level_id_to_unlock: Array = []
@export var tooltip_string: String = ""

var level_name: String = "LEVEL NAME"
var level_length_in_seconds: float = 0.0
var difficulty: int = 1
var level_id: int = 1

signal pressed

# General Functions
func _ready():
	# Get percent values
	if not GameProperties.user_data == null:
		normal_stats.value = GameProperties.user_data["level%d" % [level_id]]["normal"]
		practice_stats.value = GameProperties.user_data["level%d" % [level_id]]["practice"]
	
	# Find the level json file
	load_level_data()
	
	# Update level name text
	name_txt.text = level_name.to_upper()
	
	# Update difficulty face based on difficulty given
	match difficulty:
		1: # Easy
			face.region_rect = Rect2(0.0, 0.0, 32.0, 32.0)
		2: # Easy
			face.region_rect = Rect2(0.0, 0.0, 32.0, 32.0)
		3: # Normal
			face.region_rect = Rect2(64.0, 0.0, 32.0, 32.0)
		4: # Normal
			face.region_rect = Rect2(64.0, 0.0, 32.0, 32.0)
		5: # Hard
			face.region_rect = Rect2(96.0, 0.0, 32.0, 32.0)
		6: # Hard
			face.region_rect = Rect2(96.0, 0.0, 32.0, 32.0)
		7: # Harder
			face.region_rect = Rect2(128.0, 0.0, 32.0, 32.0)
		8: # Harder
			face.region_rect = Rect2(128.0, 0.0, 32.0, 32.0)
		9: # Insane
			face.region_rect = Rect2(160.0, 0.0, 32.0, 32.0)
		10: # Demon
			face.region_rect = Rect2(192.0, 0.0, 32.0, 32.0)
	
	# Unlockable level system
	play.tooltip_text = tooltip_string
	
	if unlockable:
		play.disabled = false
		for level_id in level_id_to_unlock:
			if GameProperties.user_data["level%d" % [level_id]]["normal"] < 100:
				play.disabled = true
				break
	
	# Length System
	var minutes = int(level_length_in_seconds) / 60
	var secs = int(level_length_in_seconds) % 60
	
	if minutes <= 0:
		length_text.text = "%d:%d SECONDS LONG" % [minutes, secs]
	else:
		length_text.text = "%d:%d MINUTE LONG" % [minutes, secs]

# Load Level Data
## Load Level Data:
## Loads the user data
## (Main Function)
func load_level_data():
	var level_data: Dictionary
	
	# Load level data
	var level_json_file_path = level_path.path_join("level.json")
	if FileAccess.file_exists(level_json_file_path):
		var file = FileAccess.open(level_json_file_path, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			var json = JSON.parse_string(content)
			if typeof(json) == TYPE_DICTIONARY:
				level_data = json
	else:
		return
	
	# Load stream
	var stream = load(level_data["SongPath"])
	
	# Update properties
	level_name = level_data["Name"]
	difficulty = level_data["Difficulty"]
	level_id = level_data["ID"]
	level_length_in_seconds = stream.get_length()

# End

# Play level
## Play level System:
## Passes the level path to game properties and loads to another scene
## (Signal Function)
func on_play_pressed():
	GameProperties.level_path = level_path
	GameProperties.current_level_id = level_id
	
	emit_signal("pressed")
