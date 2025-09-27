extends Panel

# Reference scene nodes
@onready var name_txt: Label = $LevelNamePanel/Name
@onready var face: Sprite2D = $DifficultyPanel/Face

@onready var normal_stats: ProgressBar = $StatsPanel/NormalProgress
@onready var practice_stats: ProgressBar = $StatsPanel/PracticeProgress

## Each level panel has a unique level path that basically holds a string path 
## to their respective level
@export var level_path: String = "res://files/levels/level1"
@export var level_name: String = "LEVEL NAME"
@export var difficulty: int = 1
@export var level_id: int = 1


signal pressed

# General Functions
func _ready():
	# Get percent values
	if not GameProperties.user_data == null:
		normal_stats.value = GameProperties.user_data["level%d" % [level_id]]["normal"]
		practice_stats.value = GameProperties.user_data["level%d" % [level_id]]["practice"]
	
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

# Play level
## Play level System:
## Passes the level path to game properties and loads to another scene
## (Signal Function)
func on_play_pressed():
	GameProperties.level_path = level_path
	GameProperties.current_level_id = level_id
	
	emit_signal("pressed")
