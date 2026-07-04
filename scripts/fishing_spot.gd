extends Area3D

## Simple fishing minigame: press E to cast, wait a randomized bite time,
## then a fish is added automatically.

@export var min_wait: float = 3.0
@export var max_wait: float = 6.0

@onready var wait_timer: Timer = $WaitTimer

enum State { IDLE, WAITING }
var _state: State = State.IDLE

var prompt_text: String:
	get:
		return "Balık bekleniyor..." if _state == State.WAITING else "[E] Balık Tut"


func _ready() -> void:
	add_to_group("interactable")
	wait_timer.one_shot = true
	wait_timer.timeout.connect(_on_bite)


func interact(_player: Node) -> void:
	if _state != State.IDLE:
		return
	_state = State.WAITING
	wait_timer.wait_time = randf_range(min_wait, max_wait)
	wait_timer.start()


func _on_bite() -> void:
	Inventory.add("fish", 1)
	_state = State.IDLE
