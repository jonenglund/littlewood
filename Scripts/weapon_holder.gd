extends Node2D

@export var orbit_distance: float = 13.0
@export var weapon_scale: float = 1.0

func _process(delta: float) -> void:
	# Get the player's global position (assumes WeaponHolder is a child of the player).
	var player_pos: Vector2 = get_parent().global_position
	# Get the global mouse position.
	var mouse_pos: Vector2 = get_global_mouse_position()
	# Calculate the normalized direction from the player to the mouse.
	var direction: Vector2 = (mouse_pos - player_pos).normalized()
	
	# Position this WeaponHolder at a fixed distance (orbit_distance) from the player.
	position = direction * orbit_distance
	
	# Rotate the WeaponHolder to face the mouse.
	rotation = direction.angle()
	
	# Scale the weapon if it exists as a child node.
	if has_node("Weapon"):
		$Weapon.scale = Vector2(weapon_scale, weapon_scale)
