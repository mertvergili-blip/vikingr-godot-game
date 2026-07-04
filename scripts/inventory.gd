extends Node

## Autoload singleton tracking the player's gathered resources.

signal resource_changed(resource_name: String, new_amount: int)

var resources: Dictionary = {
	"wood": 0,
	"wheat": 0,
	"fish": 0,
	"wool": 0,
	"milk": 0,
	"gold": 0,
}


func add(resource_name: String, amount: int) -> void:
	resources[resource_name] = get_amount(resource_name) + amount
	resource_changed.emit(resource_name, resources[resource_name])


func get_amount(resource_name: String) -> int:
	return resources.get(resource_name, 0)
