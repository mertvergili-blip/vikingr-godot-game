extends Area3D

## Generic NPC: wanders within a day zone or a (usually smaller/different)
## night zone depending on GameClock.get_period(), and shows a line of
## dialogue through the HUD when talked to. Talking pauses wandering.

@export var npc_name: String = "NPC"
@export var dialogue_lines: Array[String] = ["Selam, gezgin."]
@export var terrain_path: NodePath
@export var day_zone_center: Vector3 = Vector3.ZERO
@export var day_zone_radius: float = 6.0
@export var night_zone_center: Vector3 = Vector3.ZERO
@export var night_zone_radius: float = 3.0
@export var walk_speed: float = 1.6
@export var wander_interval: float = 6.0

@onready var anim_player: AnimationPlayer = find_child("AnimationPlayer", true, false)
@onready var wander_timer: Timer = $WanderTimer

var _terrain: Node
var _target: Vector2
var _talking: bool = false
var _line_index: int = 0
var _hud: CanvasLayer

var prompt_text: String:
	get:
		return "[E] Kapat" if _talking else "[E] Konuş"


func _ready() -> void:
	add_to_group("interactable")
	$NameLabel.text = npc_name
	_terrain = get_node(terrain_path)
	var hud_nodes := get_tree().get_nodes_in_group("hud")
	if not hud_nodes.is_empty():
		_hud = hud_nodes[0]

	wander_timer.wait_time = wander_interval
	wander_timer.timeout.connect(_pick_new_target)
	wander_timer.start()
	_pick_new_target()
	_snap_to_terrain()


func _current_zone() -> Array:
	if GameClock.get_period() == "night":
		return [night_zone_center, night_zone_radius]
	return [day_zone_center, day_zone_radius]


func _pick_new_target() -> void:
	var zone := _current_zone()
	var center: Vector3 = zone[0]
	var radius: float = zone[1]
	var angle := randf_range(0.0, TAU)
	var dist := randf_range(0.0, radius)
	_target = Vector2(center.x + cos(angle) * dist, center.z + sin(angle) * dist)


func _process(delta: float) -> void:
	if _talking:
		_play_anim("Idle_Talking_Loop")
		return

	var current := Vector2(position.x, position.z)
	var to_target := _target - current
	if to_target.length() > 0.3:
		var dir := to_target.normalized()
		position.x += dir.x * walk_speed * delta
		position.z += dir.y * walk_speed * delta
		look_at(position + Vector3(dir.x, 0.0, dir.y), Vector3.UP)
		_play_anim("Walk_Loop")
	else:
		_play_anim("Idle_Loop")
	_snap_to_terrain()


func _snap_to_terrain() -> void:
	position.y = _terrain.get_height(position.x, position.z)


func _play_anim(anim_name: String) -> void:
	if anim_player and anim_player.has_animation(anim_name) and anim_player.current_animation != anim_name:
		anim_player.play(anim_name)


func interact(_player: Node) -> void:
	if _talking:
		_hide_dialogue()
	else:
		_show_dialogue()


func _show_dialogue() -> void:
	_talking = true
	if _hud:
		var line: String = dialogue_lines[_line_index % dialogue_lines.size()]
		_hud.show_dialogue(npc_name, line)
		_line_index += 1


func _hide_dialogue() -> void:
	_talking = false
	if _hud:
		_hud.hide_dialogue()
