extends Node


@onready var nakama_connect_host_panel: Panel = %Network
@onready var direct_ip_host_connect: Panel = %LAN
@onready var matches_list_ui: Control = %MatchesListUI



func _ready() -> void:
	MultiplayerManager.match_joined.connect(_on_multiplayer_manager_match_joinded)
	MultiplayerManager.match_started.connect(_on_multiplayer_manager_match_started)
	MultiplayerManager.match_ip_joined.connect(_on_multiplayer_manager_match_joinded)
	
	await MultiplayerManager.initialize("127.0.0.1", 7350)
	
	LobbyManager.initialize(
		MultiplayerManager.client,
		MultiplayerManager.session,
		MultiplayerManager.socket,
		MultiplayerManager.multiplayer_bridge,
		null
	)


func _on_matches_list_ui_match_selected(match_id) -> void:
	var match_nakama = await MultiplayerManager.connect_to_match(match_id)
	
	


func _on_multiplayer_manager_match_joinded(match_nakama = null):
	$CanvasLayer/MatchUI.refresh = true
	nakama_connect_host_panel.hide()
	direct_ip_host_connect.hide()
	matches_list_ui.hide()


func _on_multiplayer_manager_match_started():
	$CanvasLayer.hide()


func _on_direct_ip_host_connect_host_requested() -> void:
	MultiplayerManager.initialize_host_ip()


func _on_direct_ip_host_connect_ip_connection_requested(ip : String) -> void:
	MultiplayerManager.connect_to_match_ip(ip)
