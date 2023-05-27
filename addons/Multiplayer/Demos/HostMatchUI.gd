extends Control


@onready var line_edit: LineEdit = $HBoxContainer/LineEdit


func _on_host_button_pressed() -> void:
	var match_id = line_edit.text
	LobbyManager.create_private_match(match_id)
