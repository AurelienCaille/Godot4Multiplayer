## LobbyManager
##
## Gere le système de lobby
## - rejoindre/creer un match privé
## - afficher/rejoindre un match publique

extends Node


var nakama_client : NakamaClient
var nakama_session : NakamaSession
var nakama_socket : NakamaSocket
var multiplayer_bridge : NakamaMultiplayerBridge
var hud

# Filters for matches finding
var min_player = 1
var max_player = 999
var limit = 100
var authoritative = true
var label = ""
var query = ""



func initialize(client : NakamaClient, session : NakamaSession, socket : NakamaSocket, multiplayer_bridge, hud_packed : PackedScene):
	nakama_client = client
	nakama_session = session
	nakama_socket = socket
	self.multiplayer_bridge = multiplayer_bridge
	
	if hud_packed and hud_packed.can_instantiate():
		hud = hud_packed.instantiate()
		add_child(hud)


### Match ###

## Récupère la liste des matches publiques
func get_public_matches() -> Array:
#	var result = await nakama_client.list_matches_async(
#		nakama_session,
#		min_player,
#		max_player,
#		limit,
#		authoritative,
#		label,
#		query)
#
#	return result.matches
	var responses : NakamaAPI.ApiRpc = await nakama_client.rpc_async(nakama_session, "listPublicMatch")

	if responses.is_exception():
		print("Error while trying to list all public match, %s" % responses)
		return []
	
	var json_payload = JSON.parse_string(responses.payload)
	
	return json_payload.matches


## Rejoind un match privé à partir d'un id
## /!\ : ne pas utiliser join_named_match car il créé un match s'il n'existe pas
func join_private_match(match_id : String):
#	var result : NakamaAsyncResult = await nakama_socket.join_match_async(match_id)
	multiplayer_bridge.join_named_match(match_id)


## Créer un match privé à partir d'un id
func create_private_match(match_id : String):
#	var result : NakamaAsyncResult = await nakama_socket.create_match_async(match_id)
	multiplayer_bridge.join_named_match(match_id)


## Créer un match public à partir d'un id
func create_public_match(match_id : String):
	var responses : NakamaAPI.ApiRpc = await nakama_client.rpc_async(nakama_session, "createPublicmatch")

	if responses.is_exception():
		print("Error while trying to create private match, %s" % responses)

	var payload_json : Dictionary = JSON.parse_string(responses.payload)
	
	MultiplayerManager.connect_to_match(payload_json["matchId"])
#	MultiplayerManager.match_joined.emit(payload_json)
	
	print_debug(responses.payload)
