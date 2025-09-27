extends Panel

@onready var p1_color: ColorPickerButton = $P1Color
@onready var p2_color: ColorPickerButton = $P2Color
@onready var skin_displayer: Node2D = $PreviewPanel/SkinDisplayer
@onready var icons: VBoxContainer = $Icons

var current_gamemode: int = 1

# General Functions
func _ready():
	# Update p1 and p2 color picker
	p1_color.color = GameProperties.user_settings["customization"]["p1_color"]
	p2_color.color = GameProperties.user_settings["customization"]["p2_color"]
	
	# Connect pressed signal of every icon
	for hbox in icons.get_children():
		for panel in hbox.get_children():
			for icon in panel.get_children():
				icon.connect("pressed", on_icon_pressed.bind( icon ) )

# Icon Customization
## Icon Customization System:
## Changes the P1 Color
## (Signal Function)
func on_p1_color_changed(color):
	GameProperties.user_settings["customization"]["p1_color"] = color
	skin_displayer.change_skin(current_gamemode)
	
	GameProperties.save_user_data()

## Icon Customization System:
## Changes the P2 Color
## (Signal Function)
func on_p2_color_changed(color):
	GameProperties.user_settings["customization"]["p2_color"] = color
	skin_displayer.change_skin(current_gamemode)
	
	GameProperties.save_user_data()

## Icon Customization System:
## Changing preview gamemode (Cube)
## (Signal Function)
func on_cube_pressed():
	current_gamemode = 1
	skin_displayer.change_skin(current_gamemode)

## Icon Customization System:
## Changing preview gamemodes (Ship)
## (Signal Function)
func on_ship_pressed():
	current_gamemode = 2
	skin_displayer.change_skin(current_gamemode)

## Icon Customization System:
## Changing preview gamemodes (Ball)
## (Signal Function)
func on_ball_pressed():
	current_gamemode = 3
	skin_displayer.change_skin(current_gamemode)

## Icon Customization System:
## Changes the user icon
## (Signal Function)
func on_icon_pressed(icon):
	if icon.unlocked:
		match icon.type:
			"cube":
				GameProperties.user_settings["customization"]["cube_skin"]["outline"] = icon.outline_coords
				GameProperties.user_settings["customization"]["cube_skin"]["p1"] = icon.p1_coords
				GameProperties.user_settings["customization"]["cube_skin"]["p2"] = icon.p2_coords
			"ship":
				GameProperties.user_settings["customization"]["ship_skin"]["outline"] = icon.outline_coords
				GameProperties.user_settings["customization"]["ship_skin"]["p1"] = icon.p1_coords
				GameProperties.user_settings["customization"]["ship_skin"]["p2"] = icon.p2_coords
			"ball":
				GameProperties.user_settings["customization"]["ball_skin"]["outline"] = icon.outline_coords
				GameProperties.user_settings["customization"]["ball_skin"]["p1"] = icon.p1_coords
				GameProperties.user_settings["customization"]["ball_skin"]["p2"] = icon.p2_coords
	
	skin_displayer.change_skin(current_gamemode)
