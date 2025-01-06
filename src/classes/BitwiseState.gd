extends Object

class_name BitwiseState

var internal_state:int = 0

func set_state_int(state_sum:int) -> void:
	internal_state = state_sum

func get_state_int() -> int:
	return internal_state

func add_state(state:int) -> void:
	internal_state |= state

func remove_state(state:int) -> void:
	internal_state &= ~state

func set_state_from_bool(state:int, value:Variant) -> void: # i lied, doesn't have to be a bool :)
	if value:
		add_state(state)
	else:
		remove_state(state)

func transition_state(from:int, to:int) -> void:
	remove_state(from)
	add_state(to)

func state_is_set(state:int) -> bool:
	return internal_state & state

func _to_string() -> String:
	return str(internal_state)
