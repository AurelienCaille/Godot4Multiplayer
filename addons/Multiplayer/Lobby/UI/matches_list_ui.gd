extends Control


@onready var list_v_box_container: VBoxContainer = $ScrollContainer/ListVBoxContainer


signal match_selected(match_id : String)


func draw_list_from_manager() -> void:
	var nakama_matches_list : Array = []
	if MultiplayerManager.has_nakama_connection:
		nakama_matches_list = await LobbyManager.get_public_matches()
	
	draw_list(nakama_matches_list)


func draw_list(matches_list : Array) -> void:
	# Clean old children
	for child in list_v_box_container.get_children():
		child.queue_free()
	
	# Create a button for each match
	for match_data in matches_list:
		var new_button := Button.new()
		list_v_box_container.add_child(new_button)
		
		new_button.text = match_data.matchId
		new_button.pressed.connect(_on_match_button_pressed.bind(match_data.matchId))


func _on_match_button_pressed(match_id : String):
	match_selected.emit(match_id)


func _on_refresh_timer_timeout() -> void:
	draw_list_from_manager()
