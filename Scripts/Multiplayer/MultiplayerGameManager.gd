class_name MultiplayerGameManager extends Node


## IP address to host
@export var Address = "127.0.0.1"
## Port to host
@export var port = 8910
## server capacity
@export var lobbySize = 4
## Scene for level
@export var lobbyScene = "res://Scenes/Levels/Lobby.tscn"
@export var levelScene = "res://Scenes/Levels/Level.tscn"

var currentScene
var inLobby : bool = true
# main peer
var peer


# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	
	peer = ENetMultiplayerPeer.new()

	if GameManager.Hosting:
		var error = peer.create_server(port, lobbySize)
		if error != OK:
			print("Cannot host  " + error)
			return

		peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
		
		#Set multiplayer
		multiplayer.set_multiplayer_peer(peer)
		print("waiting for players")
		
		send_player_information(PlayerVariables.player_name, multiplayer.get_unique_id())
	else:
		peer.create_client(Address, port)
		peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
		multiplayer.set_multiplayer_peer(peer)
		
	


#Called on server and clients when peer connects
func peer_connected(id):
	print("Player Connected " + str(id))
	
#Called on server and clients when peer disconnects
func peer_disconnected(id):
	currentScene.despawn_player(id)
	print("Player Disconnected " + str(id))

#Client-only call. When connecting to server
func connected_to_server():
	print("Connected to server!")
	#addPlayerToDict(PlayerVariables.player_name, multiplayer.get_unique_id())
	send_player_information.rpc_id(1, PlayerVariables.player_name, multiplayer.get_unique_id())

#Client-only call. When connection fails to server
func connection_failed():
	print("Connection Failed!")
	
#push player infromation to every other player
@rpc("any_peer","call_remote")
func send_player_information(playerName, id):
	#if player doesn't exst, add
	addPlayerToDict(playerName, id)
	
	# for server to send player information to 
	if multiplayer.is_server():
		for i in GameManager.Players:
			print("sending " + str(GameManager.Players[i].id))
			send_player_information.rpc(GameManager.Players[i].name, GameManager.Players[i].id)

func addPlayerToDict(playerName, id):
	if !GameManager.Players.has(id):
		GameManager.Players[id] ={
			"name" : playerName,
			"id": id
		}
	else:
		GameManager.Players[id].name = playerName
		#GameManager.Players[id].NodePath = currentScene.spawn_player(playerName, id)
	
func removePlayerFromDict():
	pass

@rpc("authority")
func start_lobby():
	currentScene = load(lobbyScene).instantiate()
	get_tree().root.add_child(currentScene)
	inLobby = true
	
	for i in GameManager.Players:
		currentScene.spawn_player(GameManager.Players[i].name, GameManager.Players[i].id)

@rpc("authority")
func start_level():
	inLobby = false
