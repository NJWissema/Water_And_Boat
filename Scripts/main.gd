extends Node3D

export (PackedScene) var boid_scene
var boids: Array = []
# Called when the node enters the scene tree for the first time.
func _ready():
	#Time to make boids. BOIDS for fishies
	for i in range(50):  # Create 50 boids
		var boid_instance = boid_scene.instance()
		boid_instance.position = Vector2(randf_range(0, 800), randf_range(0, 600))
		add_child(boid_instance)
		boids.append(boid_instance)

	for boid in boids:
		boid.set_boids(boids)  # Pass the list of boids to each instance
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
