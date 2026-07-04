extends Node

## Global day/night clock. day_night_cycle.gd (the sun) and any NPC schedule
## both read from this so they never disagree about what time it is.

signal time_changed(time_of_day: float)

@export var day_length_seconds: float = 240.0

var time_of_day: float = 0.3


func _process(delta: float) -> void:
	time_of_day = fmod(time_of_day + delta / day_length_seconds, 1.0)
	time_changed.emit(time_of_day)


## Rough day/night split used for NPC schedules, matching the sun's own
## elevation formula so lighting and NPC behavior never disagree.
func get_period() -> String:
	var elevation_sign := sin((time_of_day - 0.25) * TAU)
	return "night" if elevation_sign <= 0.0 else "day"
