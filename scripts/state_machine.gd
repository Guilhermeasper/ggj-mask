extends Node

@export var initial_state: State

var current_state: State
var states: Dictionary = { }


func _ready() -> void:
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.transition.connect(_on_child_transition)

	if initial_state:
		current_state = initial_state


func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)


func _on_child_transition(state: State, next_state_name: String) -> void:
	if state != current_state:
		return

	var next_state = states.get(next_state_name.to_lower())
	if !next_state:
		return

	if current_state:
		current_state.exit()

	next_state.enter()
	current_state = next_state
