extends Control


@onready var bg_dim: ColorRect = $BGDim
@onready var return_button: Button = $Panel/Margin/VBox/Buttons/Panel/ReturnButton
@onready var restart_button: Button = $Panel/Margin/VBox/Buttons/Panel2/RestartButton
@onready var home_button: Button = $Panel/Margin/VBox/Buttons/Panel3/HomeButton

# General Functions
func _process(delta):
	if get_tree().paused:
		bg_dim.visible = true
	else:
		bg_dim.visible = false
