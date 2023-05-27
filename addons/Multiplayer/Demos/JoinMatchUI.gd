extends Control


@onready var line_edit: LineEdit = $HBoxContainer/LineEdit


func _on_join_button_pressed() -> void:
	var match_id = line_edit.text
	LobbyManager.join_private_match(match_id)
