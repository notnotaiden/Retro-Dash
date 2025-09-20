extends Control

# Labels
@onready var attempt_text: Label = $Panel/Margins/VBox/PanelLabels/MarginsLabels/Labels/AttemptsTxt
@onready var jumps_text: Label = $Panel/Margins/VBox/PanelLabels/MarginsLabels/Labels/JumpsTxt
@onready var restart_button: Button = $Panel/Margins/VBox/MarginsButtons/Buttons/Restart/Button

# Update Labels:
## Update Labels:
## Updates the text of the label nodes
## (Main Function)
func update(attempts, jumps):
	attempt_text.text = "Attempts: %d" % [attempts]
	jumps_text.text = "Jumps: %d" % [jumps]
# End
