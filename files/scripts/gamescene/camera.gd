extends Camera2D

var shake_strength: float = 0.0
var shake_decay: float = 20.0
var rng = RandomNumberGenerator.new()

func _process(delta):
	if shake_strength > 0.0:
		# Random offset in both x and y
		offset = Vector2( rng.randf_range(-1, 1), rng.randf_range(-1, 1) ) * shake_strength
		
		# Decay the shake over time
		shake_strength = max(shake_strength - shake_decay * delta, 0.0)
	else:
		offset = Vector2.ZERO

func apply_shake(amount: float):
	shake_strength = amount
