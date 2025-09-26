extends Control

@onready var restart_button: Button = $Panel/Margin/Content/Buttons/Panel/Restart
@onready var home_button: Button = $Panel/Margin/Content/Buttons/Panel2/Home
@onready var attempts_txt: Label = $Panel/Margin/Content/Label/Panel/Panel/Margins/VBoxContainer/Attempts
@onready var jumps_txt: Label = $Panel/Margin/Content/Label/Panel/Panel/Margins/VBoxContainer/Jumps

func update(attempts, jumps):
	attempts_txt.text = "Attempts: %d" % [attempts]
	jumps_txt.text = "Jumps: %d" % [jumps]
