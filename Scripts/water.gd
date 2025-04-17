extends Node3D

@export var player: Player

@onready var player_selected: bool = is_instance_valid( player )
# Called when the node enters the scene tree for the first time.

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if player_selected:
		global_position = Vector3(player.global_position.x, global_position.y, player.global_position.z)
	pass

func _on_surface_body_body_entered(body):
	if player_selected and body == player:
		player.is_swimming = true
		player.is_floating = true

func _on_surface_body_body_exited(body):
	player.is_floating = false
	if player_selected and body == player:
		player.is_swimming = ( player.global_position.y < global_position.y )
