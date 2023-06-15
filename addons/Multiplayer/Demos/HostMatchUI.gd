extends Control


@onready var line_edit: LineEdit = $HBoxContainer/LineEdit
@onready var private_check_button: CheckButton = $HBoxContainer/PrivateCheckButton



func _on_host_button_pressed() -> void:
	var match_id = line_edit.text
	
	if private_check_button.button_pressed:
		LobbyManager.create_private_match(match_id)
	else:
		LobbyManager.create_public_match(match_id)
