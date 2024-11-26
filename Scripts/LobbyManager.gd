extends Node3D

## IP address to host
@export var PlayerSpawns : Node3D
## Player scene to be used.
@export var playerScene : PackedScene
var playerSpawns = []

# Called when the node enters the scene tree for the first time.
func _ready():
	# Create spawn locations FIFO
	for spawn in PlayerSpawns.get_children():
		playerSpawns.append(spawn)


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
