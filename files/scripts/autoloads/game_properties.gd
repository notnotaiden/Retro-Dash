extends Node

# Game Properties
## The position the player starts with in every attempt
const START_POS: Vector2 = Vector2(-64.0, 499.0)
# Different jump heights of different gamemodes
const CUBE_JUMPHEIGHT: float = -1230.0

# Holds the level data
var attempts: int = 1
var jumps: int = 0
