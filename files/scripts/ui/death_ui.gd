extends Control

# Labels
@onready var attempt_text: Label = $Panel/Margins/VBox/PanelLabels/MarginsLabels/Labels/AttemptsTxt
@onready var jumps_text: Label = $Panel/Margins/VBox/PanelLabels/MarginsLabels/Labels/JumpsTxt
@onready var restart_button: Button = $Panel/Margins/VBox/MarginsButtons/Buttons/Restart/Button
@onready var home_button: Button = $Panel/Margins/VBox/MarginsButtons/Buttons/Home/Button

@onready var new_best: Label = $NewBest

# Update Labels:
## Update Labels:
## Updates the text of the label nodes
## (Main Function)
func update(attempts, jumps):
	attempt_text.text = "Attempts: %d" % [attempts]
	jumps_text.text = "Jumps: %d" % [jumps]
# End

# New Best
## New Best:
## Displays a new best text
## (Main Function)
func show_new_best():
	new_best.visible = true
