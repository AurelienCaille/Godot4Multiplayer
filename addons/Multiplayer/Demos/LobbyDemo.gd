extends Node


func _ready() -> void:
	await MultiplayerManager.initialize("127.0.0.1", 7350)
	
	LobbyManager.initialize(
		MultiplayerManager.client,
		MultiplayerManager.session,
		MultiplayerManager.socket,
		null
	)
	
	
