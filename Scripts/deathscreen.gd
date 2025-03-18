extends Control

@export var time_slow_target: float = 0.0   # Final time_scale (0 is frozen).
@export var time_slow_duration: float = 2.0   # Duration to tween Engine.time_scale.

@export var zoom_target: Vector2 = Vector2(5, 5)  # Target zoom for the Camera2D, bigger is more zoomed in.
@export var zoom_duration: float = 2.0              # Duration to tween the camera zoom.

@export var fade_duration: float = 0.5
@export var target_alpha: float = 0.2               # (Not used for now.)

func _ready() -> void:
	# First, get the active Camera2D from the viewport.
	var camera: Camera2D = get_viewport().get_camera_2d()
	# Next, we get player
	var player = get_tree().get_first_node_in_group("Player")
	# Create a tween for the camera properties first.
	if camera:
		var camera_zoom_tween = create_tween()
		var camera_position_tween = create_tween()
		camera_position_tween.tween_property(camera, "global_position", player.global_position, zoom_duration*.75)
		# Tween the camera's zoom property.
		camera_zoom_tween.tween_property(camera, "zoom", zoom_target, zoom_duration)
		# Also tween the camera's global position to center on the player.
	else:
		print("No active Camera2D found!")
	
	# Next, create a separate tween for slowing down time.
	var time_tween = create_tween()
	time_tween.tween_property(Engine, "time_scale", time_slow_target, time_slow_duration)
	
	# (Optional: background fade could be added here.)
	
	# Connect the Continue button signal using the new syntax.
	$Panel/ContinueButton.pressed.connect(_on_ContinueButton_pressed)

func _on_ContinueButton_pressed() -> void:
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()
