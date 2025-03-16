extends Node2D

# Define our own constant for the left mouse button.
const LEFT_MOUSE_BUTTON: int = 1

@onready var bow_sprite: Sprite2D = $WoodBow2D
@onready var arrow_sprite: Sprite2D = $WoodArrow2D
@onready var anim_player: AnimationPlayer = $AnimationPlayer

# Exported variables to adjust animation speed scales.
@export var draw_speed_scale: float = 1.0   # How quickly the bow draws.
@export var fire_speed_scale: float = 1.0   # How quickly the bow fires.

# Exported variable for the arrow projectile's speed (in pixels/sec).
@export var arrow_speed: float = 500.0

# Export the arrow projectile scene (assign your arrowprojectile.tscn in the inspector).
@export var arrow_projectile_scene: PackedScene

# State tracking.
var is_drawn: bool = false    # Is the bow fully drawn and ready to fire?
var is_drawing: bool = false  # Is the bow currently drawing?

func _ready() -> void:
	# Ensure the arrow starts hidden.
	arrow_sprite.visible = false
	# Connect the animation_finished signal so we can react when an animation ends.
	anim_player.animation_finished.connect(_on_animation_finished)

func _input(event: InputEvent) -> void:
	# Listen for left mouse button events.
	if event is InputEventMouseButton and event.button_index == LEFT_MOUSE_BUTTON:
		if event.pressed:
			# On press: if not already drawing or drawn, start drawing.
			if not is_drawn and not is_drawing:
				draw_bow()
		else:
			# On release: if the bow is fully drawn, fire it.
			if is_drawn:
				fire_bow()

# Initiates the drawing animation.
func draw_bow() -> void:
	is_drawing = true
	# Set the animation speed scale for drawing.
	anim_player.speed_scale = draw_speed_scale
	anim_player.play("draw_woodbow")
	arrow_sprite.visible = false

# Initiates the firing animation.
func fire_bow() -> void:
	# Set the animation speed scale for firing.
	anim_player.speed_scale = fire_speed_scale
	anim_player.play("fire_woodbow")
	# The projectile will be spawned when the fire animation finishes.

# Callback when an animation finishes.
func _on_animation_finished(anim_name: String) -> void:
	match anim_name:
		"draw_woodbow":
			# Once drawing is complete, mark the bow as drawn.
			is_drawn = true
			is_drawing = false
			arrow_sprite.visible = true  # Show the nocked arrow.
		"fire_woodbow":
			# After firing, reset the bow state and spawn the arrow projectile.
			is_drawn = false
			arrow_sprite.visible = false
			spawn_projectile()

# Spawns an arrow projectile from the provided scene.
func spawn_projectile() -> void:
	if arrow_projectile_scene:
		var arrow_instance = arrow_projectile_scene.instantiate()
		# Set the projectile's position and rotation to match the arrow sprite.
		arrow_instance.global_position = arrow_sprite.global_position
		arrow_instance.rotation = arrow_sprite.global_rotation
		# Retrieve the weapon scale from the WeaponHolder (assumed to be the parent).
		# This assumes that the WeaponHolder node has an exported variable "weapon_scale".
		var w_scale: float = get_parent().weapon_scale
		arrow_instance.scale = Vector2(w_scale, w_scale)
		if arrow_instance.has_method("set_speed"):
			arrow_instance.set_speed(arrow_speed)
		# Add the arrow projectile to the current scene.
		get_tree().current_scene.add_child(arrow_instance)
