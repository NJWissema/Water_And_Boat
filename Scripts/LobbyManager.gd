extends Node3D

## IP address to host
@export var Address = "127.0.0.1"
## Port to host
@export var port = 8910
## server capacity
@export var lobbySize = 4
##isHost check for setting up lobby.
@export var isHost : bool
var peer


## Player scene to be used.
@export var playerScene : PackedScene
var playerSpawnIndex:=0

# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	
	if isHost:
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
	pass # Replace with function body.

#Called on server and clients when peer connects
func peer_connected(id):
	spawn_player(id)
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
			"score": 0
		}
	
	if multiplayer.is_server():
		for i in GameManager.Players:
			send_player_information.rpc(GameManager.Players[i].name, i)
			
	

func spawn_player(playerID):
	var currentPlayer = playerScene.instantiate()
	currentPlayer.name = str(GameManager.Players[playerID].id)
	#if currentPlayer.name != str(multiplayer.get_unique_id()):
		#currentPlayer.remove_child(currentPlayer.get_child(2))
	add_child(currentPlayer)
	
	for spawn in get_tree().get_nodes_in_group("PlayerSpawn"):
		if spawn.name == str(playerSpawnIndex):
			currentPlayer.global_position = spawn.global_position
	playerSpawnIndex+=1

func delete_player(playerID):
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass
