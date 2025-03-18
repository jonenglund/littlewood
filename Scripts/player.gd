extends CharacterBody2D

@export var speed: float = 200.0
@export var acceleration: float = 850.0	# How quickly the player reaches full speed.
@export var friction: float = 425.0		# How quickly the player slows down.
@export var base_anim_speed: float = 1.0	# Global multiplier for all animations.
@export var base_run_anim_speed: float = 1.3	# Base speed multiplier for the run animation.
@export var base_idle_anim_speed: float = 0.75	# Base speed multiplier for the idle animation.
@export var base_death_anim_speed: float = .5 # Base speed multiplier for the death animation
@export var max_health: int = 100

var current_health: int
var is_dead: bool = false

func _ready() -> void:
	current_health = max_health
	print("Player Health: ", current_health)

func _physics_process(delta: float) -> void:
	if is_dead:
		# When dead, we don't process movement or input.
		return
	
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
	if velocity.x < 0:
		$Idle2D.flip_h = true
		$Run2D.flip_h = true
		$Die2D.flip_h = true
	elif velocity.x > 0:
		$Idle2D.flip_h = false
		$Run2D.flip_h = false
		$Die2D.flip_h = false
	
	# --- Animation and Sprite Visibility ---
	if velocity.length() > 1:
		$Idle2D.visible = false
		$Run2D.visible = true
		if $AnimationPlayer.current_animation != "run":
			$AnimationPlayer.play("run")
		$AnimationPlayer.speed_scale = base_anim_speed * base_run_anim_speed * (velocity.length() / speed)
	else:
		$Idle2D.visible = true
		$Run2D.visible = false
		if $AnimationPlayer.current_animation != "idle":
			$AnimationPlayer.play("idle")
		$AnimationPlayer.speed_scale = base_anim_speed * base_idle_anim_speed

func take_damage(amount: int) -> void:
	current_health -= amount
	print("Player took ", amount, " damage! Health remaining: ", current_health)
	if current_health <= 0 and not is_dead:
		die()

func die() -> void:
	is_dead = true
	print("Player has died!")
	
	# Disable further input processing.
	set_process_input(false)
	
	# Stop movement.
	velocity = Vector2.ZERO
	
	# Set sprite visibility: hide idle and run, show death sprite.
	$Idle2D.visible = false
	$Run2D.visible = false
	$WeaponHolder.visible = false
	$Die2D.visible = true
	
	# Play the death animation.
	$AnimationPlayer.speed_scale = base_death_anim_speed
	$AnimationPlayer.play("die")
	# Instance and add the death screen.
	var death_screen = preload("res://scenes/DeathScreen.tscn").instantiate()
	add_child(death_screen)
