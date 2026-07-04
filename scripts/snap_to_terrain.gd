extends Node3D

## Snaps each direct child's Y position to the terrain height at its (x, z),
## so hand-placed props (camp, landmarks) sit correctly on the noise-based
## terrain without needing to precompute heights by hand in the editor.

@export var terrain_path: NodePath


func _ready() -> void:
	var terrain: Node = get_node(terrain_path)
	for child in get_children():
		if child is Node3D:
			var pos: Vector3 = child.position
			child.position.y = terrain.get_height(pos.x, pos.z)
