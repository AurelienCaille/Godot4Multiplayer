extends Node


func _ready() -> void:
	await MultiplayerManager.initialize("127.0.0.1", 7350)
	
	LobbyManager.initialize(
		MultiplayerManager.client,
		MultiplayerManager.session,
		MultiplayerManager.socket,
		MultiplayerManager.multiplayer_bridge,
		null
	)
	
	MultiplayerManager.match_joined.connect(_on_multiplayer_manager_match_joinded)
	MultiplayerManager.match_started.connect(_on_multiplayer_manager_match_started)


func _on_matches_list_ui_match_selected(match_id) -> void:
	var match_nakama = await MultiplayerManager.connect_to_match(match_id)
	
	


func _on_multiplayer_manager_match_joinded(match_nakama):
	$CanvasLayer/MatchUI.refresh = true


func _on_multiplayer_manager_match_started():
	$CanvasLayer.hide()
