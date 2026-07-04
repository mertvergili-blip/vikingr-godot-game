extends "res://scripts/npc.gd"

## Halvard is the quest giver for the main chain: talking to him checks the
## active quest, turns it in if the requirements are met, and reports
## progress otherwise.


func _show_dialogue() -> void:
	_talking = true
	if not _hud:
		return

	var text: String
	if QuestManager.is_active():
		var quest_desc: String = QuestManager.current_quest().get("desc", "")
		if QuestManager.can_turn_in():
			QuestManager.turn_in()
			text = "Aferin! %s\nŞöhretin arttı." % quest_desc
			if not QuestManager.is_active():
				text += "\nArtık meclisi toplamaya hazırım..."
		else:
			text = quest_desc
	else:
		text = "Görevlerimi tamamladın. Meclis seni bekliyor."

	_hud.show_dialogue(npc_name, text)
