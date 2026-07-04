extends Area3D

## Generic periodic-yield animal (sheep/goat/etc): interact for a resource,
## then it needs cooldown_time before it can be used again.

@export var resource_type: String = "wool"
@export var yield_amount: int = 1
@export var cooldown_time: float = 25.0
@export var action_label: String = "Yün Kırk"
@export var body_color: Color = Color.WHITE

@onready var cooldown_timer: Timer = $CooldownTimer
@onready var body_mesh: MeshInstance3D = $Body

var _on_cooldown: bool = false

var prompt_text: String:
	get:
		return "Hazırlanıyor..." if _on_cooldown else "[E] %s" % action_label


func _ready() -> void:
	add_to_group("interactable")
	cooldown_timer.one_shot = true
	cooldown_timer.timeout.connect(_on_cooldown_done)

	var material := StandardMaterial3D.new()
	material.albedo_color = body_color
	body_mesh.material_override = material


func interact(_player: Node) -> void:
	if _on_cooldown:
		return
	Inventory.add(resource_type, yield_amount)
	_on_cooldown = true
	cooldown_timer.wait_time = cooldown_time
	cooldown_timer.start()


func _on_cooldown_done() -> void:
	_on_cooldown = false
