# EnemyStats.gd
extends Resource
class_name EnemyStats

#Base Stats
@export var health: int = 100
@export var attack: int = 10
@export var defense: int = 5

#Movement Stats
@export var move_speed: float = 200.0       # Movement speed when following.
@export var speed_modifier: float = 1
@export var follow_distance: float = 25.0  # Distance to stop from the player.
