extends Control


@onready var bg_dim: ColorRect = $BGDim
@onready var return_button: Button = $Panel/Margin/VBox/Panel/PanelContainer/MarginContainer/Buttons/Panel/ReturnButton
@onready var practice_button: Button = $Panel/Margin/VBox/Panel/PanelContainer/MarginContainer/Buttons/Panel2/PracticeButton
@onready var home_button: Button = $Panel/Margin/VBox/Panel/PanelContainer/MarginContainer/Buttons/Panel3/HomeButton

# General Functions
func _process(_delta):
	if get_tree().paused:
		bg_dim.visible = true
	else:
		bg_dim.visible = false
