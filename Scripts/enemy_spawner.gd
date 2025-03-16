extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_interval: float = 5.0
@export var min_spawn_distance: float = 300.0
@export var max_spawn_distance: float = 500.0

var spawn_timer: Timer

func _ready() -> void:
	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.one_shot = false
	spawn_timer.autostart = true
	add_child(spawn_timer)
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)

func _on_spawn_timer_timeout() -> void:
	var enemy_instance = enemy_scene.instantiate()
	enemy_instance.global_position = get_spawn_position()
	enemy_instance.add_to_group("Enemies")
	get_tree().current_scene.add_child(enemy_instance)

func get_spawn_position() -> Vector2:
	var player = get_tree().get_first_node_in_group("Player")
	if not player:
		# Fallback: return a default position if no player is found.
		return Vector2.ZERO
	# Calculate a random angle between 0 and 2π (TAU).
	var random_angle = randf() * TAU
	# Choose a random distance between min_spawn_distance and max_spawn_distance.
	var random_distance = lerp(min_spawn_distance, max_spawn_distance, randf())
	# Return the spawn position relative to the player's global position.
	return player.global_position + Vector2(random_distance, 0).rotated(random_angle)
