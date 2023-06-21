extends Control

var refresh : bool = false

@onready var list_players_in_match: VBoxContainer = %ListPlayersInMatch

func _process(delta: float) -> void:
	if refresh:
		draw_players_list()

func draw_players_list():
	for c in list_players_in_match.get_children():
		c.queue_free()
	
	for player_id in MultiplayerManager.players_in_current_match:
		var new_label = Label.new()
		new_label.text = player_id
		
		list_players_in_match.add_child(new_label)


func _on_play_button_pressed() -> void:
	if multiplayer.is_server():
		MultiplayerManager.rpc_start_match.rpc()
