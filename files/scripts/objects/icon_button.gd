extends Button

@onready var icons: Sprite2D = $Icon

@export var type: String = "cube"
@export var outline_coords: Rect2
@export var p1_coords: Rect2
@export var p2_coords: Rect2
@export var display_coords: Rect2
@export var level_id_to_unlock: int = -1
@export var tooltip_string: String = ""

var unlocked: bool = true

# General Functions
func _ready():
	update_icon()
	
	tooltip_text = tooltip_string
	
	# Unlockable icon system
	if level_id_to_unlock > 0:
		if not GameProperties.user_data[ "level%d" % [level_id_to_unlock] ]["normal"] >= 100:
			disabled = true
			icons.modulate.a = 0.2
		else:
			disabled = false
			icons.modulate.a = 1.0

# Update icon
func update_icon():
	icons.region_rect = display_coords
