extends Node


var client : NakamaClient
var session : NakamaSession
var socket : NakamaSocket
var multiplayer_bridge : NakamaMultiplayerBridge


var players_in_current_match = {}

signal match_joined(match_nakama)
signal match_started

func initialize(server_ip : String, server_port : int):
	client = Nakama.create_client(
		"defaultkey",
		server_ip,
		server_port,
		"http"
	)
	
	# TODO: rework session with safe authentification
	var device_id = OS.get_unique_id() + str(randi())
	session = await(client.authenticate_device_async(device_id))
	
	if session.is_exception():
		print("error with session: %s" % [session])
	
	socket = Nakama.create_socket_from(client)
	var connected : NakamaAsyncResult = await (socket.connect_async(session))
	if connected.is_exception():
		print("An error occurred: %s" % connected)
		return
	
	multiplayer_bridge = NakamaMultiplayerBridge.new(socket)
	get_tree().get_multiplayer().set_multiplayer_peer(multiplayer_bridge.multiplayer_peer)
	
	socket.received_match_presence.connect(_on_match_presence)

	get_tree().get_multiplayer().peer_connected.connect(self._on_peer_connected)
	get_tree().get_multiplayer().peer_disconnected.connect(self._on_peer_disconnected)
	multiplayer_bridge.match_join_error.connect(self._on_match_join_error)
	multiplayer_bridge.match_joined.connect(self._on_match_joined)


func _on_match_join_error(error):
	print ("Unable to join match: ", error.message)

func _on_match_joined() -> void:
	print ("Joined match with id: ", multiplayer_bridge.match_id)

func _on_peer_connected(peer_id):
	print ("Peer joined match: ", peer_id)

func _on_peer_disconnected(peer_id):
	print ("Peer left match: ", peer_id)


func connect_to_match(match_id):
	var match_nakama = await multiplayer_bridge.join_named_match(match_id)
	
#	for player in match_nakama.presences:
#		players_in_current_match[player.user_id] = player
		
	match_joined.emit(match_nakama)

	return match_nakama


@rpc("any_peer", "call_local")
func rpc_start_match():
	match_started.emit()


func _on_match_presence(p_presence : NakamaRTAPI.MatchPresenceEvent):
	for presence in p_presence.joins:
		players_in_current_match[presence.user_id] = presence
	
	for presence in p_presence.leaves:
		players_in_current_match.erase(presence.user_id)

