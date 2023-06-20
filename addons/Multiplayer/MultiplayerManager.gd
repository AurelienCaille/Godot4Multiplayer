extends Node


var client : NakamaClient
var session : NakamaSession
var socket : NakamaSocket
var multiplayer_bridge : NakamaMultiplayerBridge


var players_in_current_match = {}

signal match_joined(match_nakama)

func initialize(server_ip : String, server_port : int):
	client = Nakama.create_client(
		"defaultkey",
		server_ip,
		server_port,
		"http"
	)
	
	# TODO: rework session with safe authentification
	var device_id = OS.get_unique_id() 
	session = await(client.authenticate_device_async(device_id))
	
	if session.is_exception():
		print("error with session: %s" % [session])
	
	socket = Nakama.create_socket_from(client)
	var connected : NakamaAsyncResult = await (socket.connect_async(session))
	if connected.is_exception():
		print("An error occurred: %s" % connected)
		return
	
	multiplayer_bridge = NakamaMultiplayerBridge.new(socket)
	get_tree().get_multiplayer().multiplayer_peer = multiplayer_bridge.multiplayer_peer
	
	socket.received_match_presence.connect(_on_match_presence)


func connect_to_match(match_id):
	var match_nakama = await socket.join_match_async(match_id)
	
	for player in match_nakama.presences:
		players_in_current_match[player.user_id] = player
		
	match_joined.emit(match_nakama)

	return match_nakama


func _on_match_presence(p_presence : NakamaRTAPI.MatchPresenceEvent):
	for presence in p_presence.joins:
		players_in_current_match[presence.user_id] = presence
	
	for presence in p_presence.leaves:
		players_in_current_match.erase(presence.user_id)

