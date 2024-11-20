extends Node3D

## IP address to host
@export var Address = "127.0.0.1"
## Port to host
@export var port = 8910
## server capacity
@export var lobbySize = 4
##isHost check for setting up lobby.
@export var playerName = "_"
var peer


## Player scene to be used.
@export var playerScene : PackedScene
var playerSpawns = []

# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	
	for spawn in get_tree().get_nodes_in_group("PlayerSpawn"):
		playerSpawns.append(spawn)
		
	if GameManager.Hosting:
		peer = ENetMultiplayerPeer.new()
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
		peer = ENetMultiplayerPeer.new()
		peer.create_client(Address, port)
		peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
		multiplayer.set_multiplayer_peer(peer)

#Called on server and clients when peer connects
func peer_connected(id):
	print("Player Connected " + str(id))
#Called on server and clients when peer disconnects
func peer_disconnected(id):
	delete_player(id)
	print("Player Disconnected " + str(id))
#Client-only call. When connecting to server
func connected_to_server():
	print("Connected to server!")
	send_player_information.rpc_id(1, PlayerVariables.player_name, multiplayer.get_unique_id())
#Client-only call. When connection fails to server
func connection_failed():
	print("Connection Failed!")

#push player infromation to every other player
@rpc("any_peer")
func send_player_information(playerName, id):
	if !GameManager.Players.has(id):
		GameManager.Players[id] ={
			"name" : playerName,
			"id": id,
			"score": 0,
			"model": spawn_player(playerName, id)
		}
		#spawn_player(id)
	
	if multiplayer.is_server():
		for i in GameManager.Players:
			send_player_information.rpc(GameManager.Players[i].name, i)
			
	

func spawn_player(playerName, playerID) -> CharacterBody3D:
	var currentPlayer = playerScene.instantiate()
	currentPlayer.name = str(playerID)
	currentPlayer.playerName = playerName
	currentPlayer.playerID = playerID
	#if currentPlayer.name != str(multiplayer.get_unique_id()):
		#currentPlayer.remove_child(currentPlayer.get_child(2))
	add_child(currentPlayer)
	
	#spawn at last used spawn location
	var spawn = playerSpawns.pop_front()
	currentPlayer.global_position = spawn.global_position
	playerSpawns.append(spawn)
	
	return currentPlayer

func delete_player(playerID):
	remove_child(GameManager.Players[playerID].model)
	print(GameManager.Players[playerID].name + " Left")



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass
