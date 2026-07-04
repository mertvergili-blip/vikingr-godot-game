extends Node

## Central Fame stat. Player Fame is earned through quests/actions; Steinar's
## Fame climbs on its own over time, creating time pressure.

signal player_fame_changed(new_fame: int)
signal steinar_fame_changed(new_fame: float)

var player_fame: int = 0
var steinar_fame: float = 20.0

const STEINAR_FAME_PER_DAY: float = 6.0

const TITLES := [
	[0, "Köylü"],
	[50, "Savaşçı"],
	[120, "Reis Adayı"],
]


func add_player_fame(amount: int) -> void:
	player_fame = max(0, player_fame + amount)
	player_fame_changed.emit(player_fame)


func add_steinar_fame(amount: float) -> void:
	steinar_fame = max(0.0, steinar_fame + amount)
	steinar_fame_changed.emit(steinar_fame)


func get_title() -> String:
	var title: String = TITLES[0][1]
	for entry in TITLES:
		if player_fame >= entry[0]:
			title = entry[1]
	return title


func _process(delta: float) -> void:
	add_steinar_fame(STEINAR_FAME_PER_DAY / GameClock.day_length_seconds * delta)
