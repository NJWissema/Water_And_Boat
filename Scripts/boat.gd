extends Node3D

	
func _physics_process(delta):
	
	position.x = 2 * sin(Time.get_ticks_usec()*0.000001)
	pass
