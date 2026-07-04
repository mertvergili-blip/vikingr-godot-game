extends CharacterBody3D

## Basic third-person controller: WASD movement relative to camera yaw,
## mouse-look orbit camera on a spring arm, jump + gravity.

@export var walk_speed: float = 4.0
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.0035
@export var camera_pitch_min_deg: float = -60.0
@export var camera_pitch_max_deg: float = 20.0

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var camera_pivot: Node3D = $CameraPivot
@onready var anim_player: AnimationPlayer = AnimHelper.find_animation_player(self)
@onready var interaction_zone: Area3D = $InteractionZone

var _current_anim: String = ""
var _hud: CanvasLayer


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	var hud_nodes := get_tree().get_nodes_in_group("hud")
	if not hud_nodes.is_empty():
		_hud = hud_nodes[0]

	if anim_player == null:
		push_error("Player: no AnimationPlayer found under Model — character will stay in bind pose.")
	else:
		print("Player animations available: ", anim_player.get_animation_list())


func _play(anim_name: String) -> void:
	if anim_player == null or _current_anim == anim_name:
		return
	var resolved := AnimHelper.resolve_animation_name(anim_player, anim_name)
	if resolved == "":
		push_warning("Player: animation '%s' not found on AnimationPlayer." % anim_name)
		return
	anim_player.play(resolved)
	_current_anim = anim_name


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera_pivot.rotate_x(-event.relative.y * mouse_sensitivity)
		camera_pivot.rotation.x = clamp(
			camera_pivot.rotation.x,
			deg_to_rad(camera_pitch_min_deg),
			deg_to_rad(camera_pitch_max_deg)
		)
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = (
			Input.MOUSE_MODE_VISIBLE
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
			else Input.MOUSE_MODE_CAPTURED
		)


func _process(_delta: float) -> void:
	var nearest: Node = interaction_zone.get_nearest()
	if _hud:
		_hud.set_prompt(nearest.prompt_text if nearest and "prompt_text" in nearest else "")
	if nearest and Input.is_action_just_pressed("interact"):
		nearest.interact(self)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * walk_speed
		velocity.z = direction.z * walk_speed
	else:
		velocity.x = move_toward(velocity.x, 0, walk_speed)
		velocity.z = move_toward(velocity.z, 0, walk_speed)

	move_and_slide()

	_update_animation()


func _update_animation() -> void:
	if not is_on_floor():
		_play("Jump_Loop")
	elif Vector2(velocity.x, velocity.z).length() > 0.5:
		_play("Walk_Loop")
	else:
		_play("Idle_Loop")
