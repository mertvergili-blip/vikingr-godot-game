extends Node3D

## Scatters CC0 Kenney Nature Kit props across the terrain, avoiding the
## flattened clearing near the origin where the village/spawn sits.

@export var terrain_path: NodePath
@export var random_seed: int = 7

const TREE_SCENES := [
	"res://assets/kenney/nature/tree_pineTallA.glb",
	"res://assets/kenney/nature/tree_pineTallB.glb",
	"res://assets/kenney/nature/tree_pineTallC.glb",
	"res://assets/kenney/nature/tree_pineRoundA.glb",
	"res://assets/kenney/nature/tree_pineRoundB.glb",
	"res://assets/kenney/nature/tree_pineRoundC.glb",
	"res://assets/kenney/nature/tree_default.glb",
	"res://assets/kenney/nature/tree_oak.glb",
]
const ROCK_SCENES := [
	"res://assets/kenney/nature/rock_largeA.glb",
	"res://assets/kenney/nature/rock_largeC.glb",
	"res://assets/kenney/nature/rock_largeE.glb",
	"res://assets/kenney/nature/rock_tallB.glb",
	"res://assets/kenney/nature/rock_tallF.glb",
	"res://assets/kenney/nature/stone_smallA.glb",
	"res://assets/kenney/nature/stone_smallC.glb",
]
const UNDERGROWTH_SCENES := [
	"res://assets/kenney/nature/plant_bush.glb",
	"res://assets/kenney/nature/plant_bushSmall.glb",
	"res://assets/kenney/nature/flower_purpleA.glb",
	"res://assets/kenney/nature/flower_redB.glb",
	"res://assets/kenney/nature/flower_yellowC.glb",
	"res://assets/kenney/nature/grass_leafs.glb",
]
const STANDING_STONE_SCENE := "res://assets/kenney/nature/stone_tallD.glb"

@export var tree_count: int = 70
@export var rock_count: int = 30
@export var undergrowth_count: int = 45
@export var standing_stone_count: int = 6
@export var standing_stone_radius: float = 6.0

var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.seed = random_seed
	var terrain: Node = get_node(terrain_path)

	_scatter(terrain, TREE_SCENES, tree_count, 0.8, 1.3)
	_scatter(terrain, ROCK_SCENES, rock_count, 0.6, 1.4)
	_scatter(terrain, UNDERGROWTH_SCENES, undergrowth_count, 0.8, 1.2)
	_place_standing_stones(terrain)


func _random_point(terrain: Node) -> Vector2:
	var half: float = terrain.terrain_size * 0.5
	var clearing_radius: float = half * terrain.clearing_radius_ratio
	var x: float
	var z: float
	while true:
		x = _rng.randf_range(-half, half)
		z = _rng.randf_range(-half, half)
		if Vector2(x, z).length() > clearing_radius * 1.6:
			break
	return Vector2(x, z)


func _scatter(terrain: Node, scene_paths: Array, count: int, min_scale: float, max_scale: float) -> void:
	for i in count:
		var point := _random_point(terrain)
		var scene_path: String = scene_paths[_rng.randi_range(0, scene_paths.size() - 1)]
		var packed: PackedScene = load(scene_path)
		var instance: Node3D = packed.instantiate()
		add_child(instance)
		instance.position = Vector3(point.x, terrain.get_height(point.x, point.y), point.y)
		instance.rotate_y(_rng.randf_range(0.0, TAU))
		var s := _rng.randf_range(min_scale, max_scale)
		instance.scale = Vector3(s, s, s)


func _place_standing_stones(terrain: Node) -> void:
	var packed: PackedScene = load(STANDING_STONE_SCENE)
	for i in standing_stone_count:
		var angle := (TAU / standing_stone_count) * i
		var x := cos(angle) * standing_stone_radius
		var z := sin(angle) * standing_stone_radius
		var instance: Node3D = packed.instantiate()
		add_child(instance)
		instance.position = Vector3(x, terrain.get_height(x, z), z)
		instance.rotation = Vector3(_rng.randf_range(-0.05, 0.05), angle, _rng.randf_range(-0.05, 0.05))
