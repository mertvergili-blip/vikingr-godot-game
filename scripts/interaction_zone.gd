extends Area3D

## Tracks interactable Area3D nodes (group "interactable") currently in range
## and reports the nearest one so the player can act on it and the HUD can
## show a prompt.

var _nearby: Array[Node] = []


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)


func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("interactable") and not _nearby.has(area):
		_nearby.append(area)


func _on_area_exited(area: Area3D) -> void:
	_nearby.erase(area)


func get_nearest() -> Node:
	var candidates := _nearby.filter(func(n):
		if not is_instance_valid(n):
			return false
		return not n.has_method("can_interact") or n.can_interact()
	)
	if candidates.is_empty():
		return null
	var nearest: Node = candidates[0]
	var nearest_dist: float = global_position.distance_squared_to(nearest.global_position)
	for area in candidates:
		var dist: float = global_position.distance_squared_to(area.global_position)
		if dist < nearest_dist:
			nearest = area
			nearest_dist = dist
	return nearest
