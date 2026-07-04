extends StaticBody3D

## Procedurally builds a gently rolling island terrain from noise, flattening
## a clearing near the world origin for the village/spawn point.

@export var terrain_size: float = 200.0
@export var resolution: int = 80
@export var height_scale: float = 8.0
@export var noise_frequency: float = 0.012
@export var noise_seed: int = 1337
@export var clearing_radius_ratio: float = 0.15

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D


func _ready() -> void:
	var noise := FastNoiseLite.new()
	noise.seed = noise_seed
	noise.frequency = noise_frequency
	noise.fractal_octaves = 4

	var verts_per_side := resolution + 1
	var half := terrain_size * 0.5
	var step := terrain_size / resolution

	var heights := PackedFloat32Array()
	heights.resize(verts_per_side * verts_per_side)

	for z in verts_per_side:
		for x in verts_per_side:
			var wx := -half + x * step
			var wz := -half + z * step
			var dist_ratio: float = Vector2(wx, wz).length() / half
			var falloff: float = clamp(dist_ratio, clearing_radius_ratio, 1.0)
			heights[z * verts_per_side + x] = noise.get_noise_2d(wx, wz) * height_scale * falloff

	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	for z in verts_per_side:
		for x in verts_per_side:
			var wx := -half + x * step
			var wz := -half + z * step
			var h: float = heights[z * verts_per_side + x]
			st.set_uv(Vector2(float(x) / resolution, float(z) / resolution))
			st.add_vertex(Vector3(wx, h, wz))

	for z in resolution:
		for x in resolution:
			var i0 := z * verts_per_side + x
			var i1 := i0 + 1
			var i2 := i0 + verts_per_side
			var i3 := i2 + 1
			st.add_index(i0)
			st.add_index(i2)
			st.add_index(i1)
			st.add_index(i1)
			st.add_index(i2)
			st.add_index(i3)

	st.generate_normals()

	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.33, 0.4, 0.21)
	material.roughness = 0.95

	mesh_instance.mesh = st.commit()
	mesh_instance.material_override = material

	var shape := HeightMapShape3D.new()
	shape.map_width = verts_per_side
	shape.map_depth = verts_per_side
	shape.map_data = heights
	collision_shape.shape = shape
	collision_shape.scale = Vector3(step, 1.0, step)
