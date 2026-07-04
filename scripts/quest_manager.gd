extends Node

## Halvard's 5-quest chain. Quests 1-4 are resource turn-ins; quest 5
## (a successful raid) is a manual flag set once the England scene exists.

signal quest_advanced(index: int)
signal all_quests_completed()

var current_index: int = 0
var raid_completed: bool = false

var quests: Array[Dictionary] = [
	{"desc": "Halvard için 20 odun topla.", "resource": "wood", "amount": 20, "fame": 15},
	{"desc": "Halvard için 15 buğday topla.", "resource": "wheat", "amount": 15, "fame": 15},
	{"desc": "Halvard için 10 balık topla.", "resource": "fish", "amount": 10, "fame": 15},
	{"desc": "Uzun gemi için 40 odun ve 15 buğday getir.", "resources": {"wood": 40, "wheat": 15}, "fame": 15},
	{"desc": "İngiltere'ye başarılı bir akın düzenle.", "manual": true, "fame": 20},
]


func is_active() -> bool:
	return current_index < quests.size()


func current_quest() -> Dictionary:
	return quests[current_index] if is_active() else {}


func _requirements() -> Dictionary:
	var q := current_quest()
	if q.has("resources"):
		return q["resources"]
	if q.has("resource"):
		return {q["resource"]: q["amount"]}
	return {}


func can_turn_in() -> bool:
	if not is_active():
		return false
	var q := current_quest()
	if q.has("manual"):
		return raid_completed
	for res_name in _requirements():
		if Inventory.get_amount(res_name) < _requirements()[res_name]:
			return false
	return true


func turn_in() -> void:
	if not can_turn_in():
		return
	var q := current_quest()
	for res_name in _requirements():
		Inventory.add(res_name, -_requirements()[res_name])
	Fame.add_player_fame(q["fame"])
	current_index += 1
	quest_advanced.emit(current_index)
	if current_index >= quests.size():
		all_quests_completed.emit()


## Human-readable status for the HUD quest tracker.
func progress_text() -> String:
	if not is_active():
		return "Tüm görevler tamamlandı. Meclis seni bekliyor."
	var q := current_quest()
	if q.has("manual"):
		return q["desc"]
	var reqs := _requirements()
	var parts: Array[String] = []
	for res_name in reqs:
		parts.append("%d/%d %s" % [Inventory.get_amount(res_name), reqs[res_name], res_name])
	var joined := ""
	for i in parts.size():
		joined += parts[i]
		if i < parts.size() - 1:
			joined += ", "
	return "%s (%s)" % [q["desc"], joined]
