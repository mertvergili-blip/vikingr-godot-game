extends Area3D

## Simple farm plot: plant (free) -> grows over grow_time seconds -> harvest
## yields wheat and resets the plot to empty.

enum State { EMPTY, GROWING, READY }

@export var grow_time: float = 45.0
@export var yield_amount: int = 8

@onready var growing_crop: Node3D = $GrowingCrop
@onready var ready_crop: Node3D = $ReadyCrop
@onready var grow_timer: Timer = $GrowTimer

var _state: State = State.EMPTY

var prompt_text: String:
	get:
		match _state:
			State.EMPTY:
				return "[E] Buğday Ek"
			State.READY:
				return "[E] Hasat Et"
			_:
				return ""


func _ready() -> void:
	add_to_group("interactable")
	growing_crop.visible = false
	ready_crop.visible = false
	grow_timer.one_shot = true
	grow_timer.timeout.connect(_on_grown)


func can_interact() -> bool:
	return _state != State.GROWING


func interact(_player: Node) -> void:
	match _state:
		State.EMPTY:
			_state = State.GROWING
			growing_crop.visible = true
			grow_timer.wait_time = grow_time
			grow_timer.start()
		State.READY:
			Inventory.add("wheat", yield_amount)
			_state = State.EMPTY
			ready_crop.visible = false


func _on_grown() -> void:
	_state = State.READY
	growing_crop.visible = false
	ready_crop.visible = true
