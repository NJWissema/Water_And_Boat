extends Node3D

## Player scene to be used.
@export var playerScene : PackedScene
##isHost check for setting up lobby.
@export var isHost : bool
# Called when the node enters the scene tree for the first time.
func _ready():
	#var index = 0
	#for i in GameManager.Players:
		#var currentPlayer = playerScene.instantiate()
		#currentPlayer.name = str(GameManager.Players[i].id)
		#if currentPlayer.name != str(multiplayer.get_unique_id()):
			#currentPlayer.remove_child(currentPlayer.get_child(2))
		#add_child(currentPlayer)
		#
		#for spawn in get_tree().get_nodes_in_group("PlayerSpawn"):
			#if spawn.name == str(index):
				#currentPlayer.global_position = spawn.global_position
		#index+=1
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass
