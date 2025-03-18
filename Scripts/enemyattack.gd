extends State
class_name EnemyAttack

@export var enemy: CharacterBody2D		# Reference to the enemy instance.
@export var attack_range: float = 40.0	# Distance at which the enemy can attack.
@export var attack_damage: int = 10		# Damage dealt per attack.
@export var attack_cooldown: float = 1.0	# Time between attacks.

var player: CharacterBody2D
var is_attacking: bool = false

func Enter() -> void:
	# When entering the attack state, locate the player and ensure the enemy stops moving.
	player = get_tree().get_first_node_in_group("Player")
	enemy.velocity = Vector2.ZERO
	is_attacking = false

func Physics_Update(delta: float) -> void:
	if not player:
		return
	
	var distance = enemy.global_position.distance_to(player.global_position)
	# If within attack range and not already attacking, attack.
	if distance <= attack_range and not is_attacking:
		is_attacking = true
		perform_attack()

func perform_attack() -> void:
	# Ensure the enemy remains stationary.
	enemy.velocity = Vector2.ZERO
	if player.has_method("take_damage") and !enemy.is_dead:
		player.take_damage(attack_damage)
		print("Enemy attacked player for ", attack_damage, " damage!")
	# Wait for cooldown before transitioning back to follow.
	await get_tree().create_timer(attack_cooldown).timeout
	is_attacking = false
	emit_signal("Transitioned", self, "follow")
