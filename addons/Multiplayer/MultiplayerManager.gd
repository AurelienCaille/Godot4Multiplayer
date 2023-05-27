extends Node


var client : NakamaClient
var session : NakamaSession
var socket : NakamaSocket
var multiplayer_bridge : NakamaMultiplayerBridge


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
