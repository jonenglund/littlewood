extends Node2D

# Inspector variables.
@export var base_speed: float = 500.0
@export var speed_variance: float = 0.2           # ±20% variance in arrow speed.
@export var wobble_amplitude: float = 5.0           # Base amplitude in pixels.
@export var wobble_frequency: float = 2.0           # Base frequency in cycles per second.
@export var wobble_amplitude_variance: float = 0.2    # ±20% amplitude variance.
@export var wobble_frequency_variance: float = 0.2    # ±20% frequency variance.
@export var amplitude_speed_multiplier: float = 0.01  # How much amplitude scales with speed.
@export var deceleration: float = 0.5               # Exponential deceleration rate.
@export var lifetime: float = 2.0                   # Lifetime of the arrow in seconds.
@export var max_rotation_offset: float = deg_to_rad(5.0)  # Maximum visual rotation offset (radians).
@export var trajectory_deviation_rate: float = 0.1   # Radians per second multiplier for trajectory deviation.
@export var damage: int = 30 

var time_elapsed: float = 0.0
var speed: float = 0.0           # Working speed that decays over time.
var initial_speed: float = 0.0   # Speed at spawn (after variance applied).
var base_rotation: float = 0.0   # The arrow’s initial movement rotation (set at spawn).

# Random factors for wobble variance.
var amplitude_random_factor: float = 1.0
var frequency_random_factor: float = 1.0
# Curvature factor for trajectory deviation. This is determined once at spawn.
var curvature_factor: float = 0.0

func _ready() -> void:
	# Save the arrow’s starting rotation as the baseline.
	base_rotation = rotation
	# Set the working speed based on the exported base_speed, applying random variance.
	speed = base_speed * (1.0 + randf_range(-speed_variance, speed_variance))
	initial_speed = speed

	# Determine random multipliers for the wobble.
	amplitude_random_factor = 1.0 + randf_range(-wobble_amplitude_variance, wobble_amplitude_variance)
	frequency_random_factor = 1.0 + randf_range(-wobble_frequency_variance, wobble_frequency_variance)
	
	# Determine the curvature factor using a cubic bias toward 0 so that most arrows fly nearly straight.
	curvature_factor = pow((randf() - 0.5) * 2.0, 3)
	
	# After 'lifetime' seconds, remove the arrow.
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _process(delta: float) -> void:
	time_elapsed += delta
	
	# Apply exponential deceleration.
	speed *= exp(-deceleration * delta)
	
	# Calculate a deviation angle that increases over time.
	var deviation_angle: float = trajectory_deviation_rate * curvature_factor * time_elapsed
	# The current movement direction is the initial direction plus the deviation.
	var current_direction: float = base_rotation + deviation_angle
	
	# Recalculate wobble parameters based on current speed.
	var current_amplitude = wobble_amplitude * amplitude_random_factor * (speed * amplitude_speed_multiplier)
	var current_frequency = wobble_frequency * frequency_random_factor * (speed / initial_speed)
	
	# Compute forward movement along the (possibly curved) trajectory.
	var forward: Vector2 = Vector2.RIGHT.rotated(current_direction) * speed * delta
	# Compute the perpendicular vector (for the wobble effect).
	var perpendicular: Vector2 = Vector2.RIGHT.rotated(current_direction + PI / 2)
	# Calculate the wobble offset using a sine wave.
	var wobble_offset: float = current_amplitude * sin(2 * PI * current_frequency * time_elapsed)
	
	# Update the arrow's position.
	position += forward + perpendicular * wobble_offset
	
	# Compute a slight visual rotation offset (counter-tilt) based on the wobble.
	var rotation_offset: float = -max_rotation_offset * sin(2 * PI * current_frequency * time_elapsed)
	# Set the arrow's visual rotation to the current trajectory plus the rotation offset.
	rotation = current_direction + rotation_offset


func _on_area_2d_body_entered(body: Node) -> void:
	if body.is_in_group("Enemies"):
		print("Enemy hit: ", body.name)
		# Call the enemy's damage function.
		if body.has_method("take_damage"):
			body.take_damage(damage)
		# Remove the arrow after hitting an enemy.
		queue_free()
