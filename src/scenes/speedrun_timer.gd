extends Label

@onready var scene_root = $"../.."

var speedrun_millis :float = 0

func _process(delta:float) -> void:
	if scene_root.speedrun_state == scene_root.SPEEDRUN_ACTIVE:
		if not visible: show()
		speedrun_millis += delta * 1000
		text = get_time_repr_from_millis(speedrun_millis)
	elif scene_root.speedrun_state == scene_root.NOT_SPEEDRUNNING:
		if visible: hide()

func get_time_repr_from_millis(time:float) -> String:
	var millis_int :int = int(time)
	
	var minutes = 0; var seconds = 0
	
	while millis_int > 60000:
		minutes += 1
		millis_int -= 60000
	while millis_int > 1000:
		seconds += 1
		millis_int -= 1000
	
	var minutes_repr = str(minutes)
	var seconds_repr = str(seconds) if seconds >= 10 else "0" + str(seconds)
	var millis_repr  = str(millis_int) if millis_int >= 100 else ("0" + str(millis_int) if millis_int >= 10 else "00" + str(millis_int))
	return str(minutes_repr) + ":" + str(seconds_repr) + "." + str(millis_repr)
