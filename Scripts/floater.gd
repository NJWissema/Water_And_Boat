extends Node3D


#Floaters calculate the distance to water surface based on the parameters of the water in the simulation
#arrow displaying direction to water surface based on function

@onready var arrow: Node3D = $Arrow
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


#Approximate the height of the water
func wave_height_calc():
	pass
