extends CanvasLayer

## Top-left resource tally and a bottom-center contextual interaction prompt.

@onready var resource_labels: Dictionary = {
	"wood": $Margin/ResourceList/Wood,
	"wheat": $Margin/ResourceList/Wheat,
	"fish": $Margin/ResourceList/Fish,
	"wool": $Margin/ResourceList/Wool,
	"milk": $Margin/ResourceList/Milk,
	"gold": $Margin/ResourceList/Gold,
}

const RESOURCE_LABELS_TR: Dictionary = {
	"wood": "Odun",
	"wheat": "Buğday",
	"fish": "Balık",
	"wool": "Yün",
	"milk": "Süt",
	"gold": "Altın",
}

@onready var prompt_label: Label = $PromptLabel
@onready var dialogue_panel: PanelContainer = $DialoguePanel
@onready var speaker_label: Label = $DialoguePanel/Margin/VBox/Speaker
@onready var line_label: Label = $DialoguePanel/Margin/VBox/Line


func _ready() -> void:
	add_to_group("hud")
	Inventory.resource_changed.connect(_on_resource_changed)
	for resource_name in resource_labels:
		_update_label(resource_name, Inventory.get_amount(resource_name))
	set_prompt("")
	hide_dialogue()


func show_dialogue(speaker: String, text: String) -> void:
	speaker_label.text = speaker
	line_label.text = text
	dialogue_panel.visible = true


func hide_dialogue() -> void:
	dialogue_panel.visible = false


func _on_resource_changed(resource_name: String, new_amount: int) -> void:
	_update_label(resource_name, new_amount)


func _update_label(resource_name: String, amount: int) -> void:
	if resource_labels.has(resource_name):
		resource_labels[resource_name].text = "%s: %d" % [RESOURCE_LABELS_TR[resource_name], amount]


func set_prompt(text: String) -> void:
	prompt_label.text = text
	prompt_label.visible = text != ""
