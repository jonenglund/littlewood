extends CharacterBody2D

@export var speed: float = 200.0
@export var acceleration: float = 850.0  # How quickly the player reaches full speed.
@export var friction: float = 425.0       # How quickly the player slows down.
@export var base_anim_speed: float = 1.0  # Global multiplier for all animations.
@export var base_run_anim_speed: float = 1.3  # Base speed multiplier for the run animation.
@export var base_idle_anim_speed: float = .75  # Base speed multiplier for the idle animation.
@export var max_health: int = 100

var current_health: int
func _ready() -> void:
	current_health = max_health
	print("Player Health: ", current_health)
func _physics_process(delta: float) -> void:
	# --- Input and Movement ---
	var input_vector: Vector2 = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	if input_vector != Vector2.ZERO:
		input_vector = input_vector.normalized()
	
	var target_velocity: Vector2 = input_vector * speed
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	
	move_and_slide()
	
	# --- Sprite Flipping ---
	# Flip both sprites so they always face the direction of movement.
	if velocity.x < 0:
		$Idle2D.flip_h = true
		$Run2D.flip_h = true
	elif velocity.x > 0:
		$Idle2D.flip_h = false
		$Run2D.flip_h = false
	
	# --- Animation and Sprite Visibility ---
	if velocity.length() > 1:
		# Running: show Run2D and hide Idle2D.
		$Idle2D.visible = false
		$Run2D.visible = true
		
		if $AnimationPlayer.current_animation != "run":
			$AnimationPlayer.play("run")
		
		# Adjust run animation speed based on movement.
		$AnimationPlayer.speed_scale = base_anim_speed * base_run_anim_speed * (velocity.length() / speed)
	else:
		# Idle: show Idle2D and hide Run2D.
		$Idle2D.visible = true
		$Run2D.visible = false
		
		if $AnimationPlayer.current_animation != "idle":
			$AnimationPlayer.play("idle")
		
		$AnimationPlayer.speed_scale = base_anim_speed * base_idle_anim_speed

func take_damage(amount: int) -> void:
	current_health -= amount
	print("Player took ", amount, " damage! Health remaining: ", current_health)
	if current_health <= 0:
		die()

func die() -> void:
	print("Player has died!")
	# Add death behavior (disable controls, play animation, etc.)
