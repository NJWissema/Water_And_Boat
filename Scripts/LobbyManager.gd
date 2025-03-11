extends Node3D

## IP address to host
@export var PlayerSpawns : Node3D
## Player scene to be used.
@export var playerScene : Player
var playerSpawns = []

# Called when the node enters the scene tree for the first time.
func _ready():
	# Create spawn locations FIFO
	for spawn in PlayerSpawns.get_children():
		playerSpawns.append(spawn)

	# Spawn players
	for i in GameManager.Players:
		spawn_player(GameManager.Players[i].name, GameManager.Players[i].id)

func spawn_player(playerName, playerID):
	
	var currentPlayer = playerScene.instantiate()
	currentPlayer.name = str(GameManager.Players[playerID].id)
	currentPlayer.playerName = playerName
	currentPlayer.playerID = playerID

	add_child(currentPlayer)
	
	#spawn at last used spawn location
	var spawn = playerSpawns.pop_front()
	currentPlayer.global_position = spawn.global_position
	playerSpawns.append(spawn)
	
	#return currentPlayer.get_path()

func despawn_player(playerID):
	get_node(GameManager.Players[playerID].NodePath).queue_free()
	print(GameManager.Players[playerID].name + " Left")
	GameManager.Players.erase(playerID)
