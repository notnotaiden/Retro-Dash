extends Button

@onready var icons: Sprite2D = $Icon

@export var type: String = "cube"
@export var outline_coords: Rect2
@export var p1_coords: Rect2
@export var p2_coords: Rect2
@export var display_coords: Rect2

var unlocked: bool = true

# General Functions
func _ready():
	update_icon()

# Update icon
func update_icon():
	icons.region_rect = display_coords
