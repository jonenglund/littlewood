extends State
class_name EnemyFollow

@export var enemy: CharacterBody2D
var player: CharacterBody2D

func Enter() -> void:
	# When entering follow, locate the player.
	player = get_tree().get_first_node_in_group("Player")

func Exit() -> void:
	# Optional cleanup on exit.
	pass

func Update(delta: float) -> void:
	# You can add non-physics updates here if needed.
	pass

func Physics_Update(delta: float) -> void:
	var direction = player.global_position - enemy.global_position
	# If enemy is further than follow_distance, follow the player.
	if direction.length() > enemy.stats.follow_distance:
		enemy.velocity = direction.normalized() * enemy.stats.move_speed
	else:
		# Within attack range: signal transition to the attack state.
		emit_signal("Transitioned", self, "attack")
