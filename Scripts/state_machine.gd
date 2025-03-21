extends Node2D

@export var initial_state: State
var current_state: State
var states: Dictionary = {}

func _ready() -> void:
	# Loop through children and register those that are states.
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.Transitioned.connect(on_child_transition)
	if initial_state:
		initial_state.Enter()
		current_state = initial_state

func _process(delta: float) -> void:
	if current_state:
		current_state.Update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.Physics_Update(delta)

func on_child_transition(state: State, new_state_name: String) -> void:
	if state != current_state:
		return
	
	var new_state = states.get(new_state_name.to_lower())
	if new_state == null:
		return
	
	if current_state:
		current_state.Exit()
	new_state.Enter()
	current_state = new_state
