extends Button

@onready var texture: Sprite2D = $Texture

var state: bool = false

# General functions
func _ready():
	state = GameProperties.user_settings["settings"]["troll_mode"]

func _process(_delta):
	if state == true:
		texture.region_rect = Rect2(0.0, 0.0, 32.0, 32.0)
	if state == false:
		texture.region_rect = Rect2(32.0, 0.0, 32.0, 32.0)

# Fires off a siganl then changes the state var
func _on_pressed():
	state = !state
	GameProperties.user_settings["settings"]["troll_mode"] = state
	GameProperties.save_user_data()
