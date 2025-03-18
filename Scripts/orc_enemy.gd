extends CharacterBody2D
class_name OrcEnemy

@export var stats: EnemyStats
@export var deathtimer: float = 1.5

# Variance factors (e.g., 0.2 means ±20% variance)
@export var speed_variance: float = 0.2    # Variance for movement speed.
@export var health_variance: float = 0.1   # Variance for health.
@export var size_variance: float = 0.1     # Variance for enemy scale.

# New exported variables for animation speed scaling.
@export var default_move_speed: float = 40.0         # The base move speed that maps to animation speed_scale = 1.
@export var animation_speed_multiplier: float = 1.0    # Multiplier to fine-tune the animation speed scale.

var is_dead: bool = false

func _ready() -> void:
	# Duplicate the stats so each enemy instance has its own copy.
	stats = stats.duplicate() as EnemyStats
	
	# Store the base values from the stats resource.
	var base_health = stats.health
	var base_speed = stats.move_speed
	
	# Determine a random size multiplier.
	var size_multiplier = 1.0 + randf_range(-size_variance, size_variance)
	# Apply this multiplier to the enemy's scale.
	scale = Vector2.ONE * size_multiplier
	
	# Adjust health: larger enemies get more health; smaller ones get less.
	stats.health = base_health * size_multiplier * (1.0 + randf_range(-health_variance, health_variance))
	# Adjust movement speed inversely: larger enemies move slower, smaller ones faster.
	stats.move_speed = base_speed / size_multiplier * (1.0 + randf_range(-speed_variance, speed_variance))
	
	print("Enemy Health: ", stats.health, " | Move Speed: ", stats.move_speed, " | Size Multiplier: ", size_multiplier)
	all_sprites_invis()

func _physics_process(_delta: float) -> void:
	if is_dead:
		return
	
	move_and_slide()
	
	# When moving, play run animation and adjust speed_scale based on move_speed.
	if velocity.length() > 0:
		$EnemySprite2D/IdleSprite2D.visible = false
		$EnemySprite2D/RunSprite2D.visible = true
		$EnemyAnimationPlayer.play("run")
		# Calculate the animation speed scale:
		$EnemyAnimationPlayer.speed_scale = (stats.move_speed / default_move_speed) * animation_speed_multiplier
	else:
		$EnemySprite2D/RunSprite2D.visible = false
		$EnemySprite2D/IdleSprite2D.visible = true
		$EnemyAnimationPlayer.play("idle")
		$EnemyAnimationPlayer.speed_scale = 1.0
		
	# Flip sprites horizontally based on movement direction.
	if velocity.x > 0:
		for child in $EnemySprite2D.get_children():
			child.flip_h = false
	else:
		for child in $EnemySprite2D.get_children():
			child.flip_h = true

func take_damage(damage_amount: int) -> void:
	if is_dead:
		return
	
	stats.health -= damage_amount
	print("Orc hit! Health remaining: ", stats.health)
	
	if stats.health <= 0:
		die()

func die() -> void:
	is_dead = true
	all_sprites_invis()
	set_physics_process(false)
	$HitBox.call_deferred("set_disabled", true)
	$EnemySprite2D/DieSprite2D.visible = true
	$EnemyAnimationPlayer.play("die")
	remove_from_group("Enemies")
	await get_tree().create_timer(deathtimer).timeout
	queue_free()

func all_sprites_invis() -> void:
	for child in $EnemySprite2D.get_children():
		child.visible = false
