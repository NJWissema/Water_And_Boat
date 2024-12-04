extends Node3D

## IP address to host
@export var PlayerSpawns : Node3D
## Player scene to be used.
@export var playerScene = "res://Scenes/SubScenes/Player.tscn"
var playerSpawns = []

# Called when the node enters the scene tree for the first time.
func _ready():
	# Create spawn locations FIFO
	for spawn in PlayerSpawns.get_children():
		playerSpawns.append(spawn)


func spawn_player(playerName, playerID) -> NodePath:
	var currentPlayer = load(playerScene).instantiate()
	
	currentPlayer.name = str(playerID)
	currentPlayer.playerName = playerName
	currentPlayer.playerID = playerID

	add_child(currentPlayer)
	
	#spawn at last used spawn location
	var spawn = playerSpawns.pop_front()
	currentPlayer.global_position = spawn.global_position
	playerSpawns.append(spawn)
	
	return currentPlayer.get_path()

func delete_player(playerID):
	get_node(GameManager.Players[playerID].NodePath).queue_free()
	print(GameManager.Players[playerID].name + " Left")
	GameManager.Players.erase(playerID)
