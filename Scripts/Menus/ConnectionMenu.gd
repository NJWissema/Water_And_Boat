extends Control


@export var multiplayerManager = "res://Scenes/Multiplayer/MultiplayerGameManager.tscn"
# Called when the node enters the scene tree for the first time.
func _ready():
	#multiplayer.peer_connected.connect(peer_connected)
	#multiplayer.peer_disconnected.connect(peer_disconnected)
	#multiplayer.connected_to_server.connect(connected_to_server)
	#multiplayer.connection_failed.connect(connection_failed)
	pass # Replace with function body.


#Called on server and clients when peer connects
#func peer_connected(id):
	#print("Player Connected " + str(id))
##Called on server and clients when peer disconnects
#func peer_disconnected(id):
	#print("Player Disconnected " + str(id))
##Client-only call. When connecting to server
#func connected_to_server():
	#print("Connected to server!")
	#send_player_information.rpc_id(1, $VBoxContainer/Name.text, multiplayer.get_unique_id())
##Client-only call. When connection fails to server
#func connection_failed():
	#print("Connection Failed!")

#@rpc("any_peer")
#func send_player_information(playerName, id):
	#if !GameManager.Players.has(id):
		#GameManager.Players[id] ={
			#"name" : playerName,
			#"id": id,
			#"score": 0
		#}
	#
	#if multiplayer.is_server():
		#for i in GameManager.Players:
			#send_player_information.rpc(GameManager.Players[i].name, i)

func start_game():
	var MultiplayerManager = load(multiplayerManager).instantiate()
	get_tree().root.add_child(MultiplayerManager)
	self.queue_free()

func _on_host_button_pressed():
	GameManager.Hosting = true
	start_game()


func _on_join_button_pressed():
	GameManager.Hosting = false
	start_game()


func _on_name_text_changed(new_text):
	PlayerVariables.player_name = new_text
