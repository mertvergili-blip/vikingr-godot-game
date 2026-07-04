extends Area3D

## Choppable tree: yields wood, swaps to a stump visual, and regrows after
## respawn_time seconds.

@export var yield_amount: int = 5
@export var respawn_time: float = 30.0

@onready var tree_model: Node3D = $TreeModel
@onready var stump_model: Node3D = $StumpModel
@onready var respawn_timer: Timer = $RespawnTimer

var prompt_text: String = "[E] Ağacı Kes"
var _chopped: bool = false


func _ready() -> void:
	add_to_group("interactable")
	stump_model.visible = false
	respawn_timer.wait_time = respawn_time
	respawn_timer.one_shot = true
	respawn_timer.timeout.connect(_on_respawn)


func can_interact() -> bool:
	return not _chopped


func interact(_player: Node) -> void:
	if _chopped:
		return
	Inventory.add("wood", yield_amount)
	_chopped = true
	tree_model.visible = false
	stump_model.visible = true
	respawn_timer.start()


func _on_respawn() -> void:
	_chopped = false
	tree_model.visible = true
	stump_model.visible = false
