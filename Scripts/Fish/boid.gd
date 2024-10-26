extends Node3D

var velocity: Vector3
var acceleration: Vector3
var max_speed: float = 100.0
var max_force: float = 10.0

# Reference to the boids in the scene
var boids: Array

# Parameters for steering behaviors
var separation_distance: float = 25.0
var alignment_distance: float = 50.0
var cohesion_distance: float = 50.0

func _ready():
	position = position
	velocity = Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)).normalized() * max_speed

func set_boids(boids_array: Array):
	boids = boids_array

func _process(delta: float):
	update_movement()
	position += velocity * delta
	position = position.clamp(Vector3(0, 0, 0), get_viewport().size)
	rotation = Vector3(0, 0, 0).direction_to(velocity)

func update_movement():
	var separation_force = separate()
	var alignment_force = align()
	var cohesion_force = cohere()

	acceleration = separation_force + alignment_force + cohesion_force
	acceleration = acceleration.maxf(max_force)

	velocity += acceleration
	velocity = velocity.maxf(max_speed)

func separate():
	var steer = Vector3.ZERO
	var total = 0

	for boid in boids:
		var distance = position.distance_to(boid.position)
		if distance > 0 and distance < separation_distance:
			var diff = (position - boid.position).normalized()
			steer += diff / distance  # Weight by distance
			total += 1

	if total > 0:
		steer /= total
		steer = steer.normalized() * max_speed
		steer -= velocity
		return steer.clamped(max_force)

	return Vector3.ZERO

func align():
	var steer: Vector3
	var sum = Vector3.ZERO
	var total = 0

	for boid in boids:
		var distance = position.distance_to(boid.position)
		if distance > 0 and distance < alignment_distance:
			sum += boid.velocity
			total += 1

	if total > 0:
		sum /= total
		sum = sum.normalized() * max_speed
		steer = sum - velocity
		return steer.maxf(max_force)

	return Vector3.ZERO

func cohere():
	var center_of_mass = Vector3.ZERO
	var total = 0

	for boid in boids:
		var distance = position.distance_to(boid.position)
		if distance > 0 and distance < cohesion_distance:
			center_of_mass += boid.position
			total += 1

	if total > 0:
		center_of_mass /= total
		return seek(center_of_mass)

	return Vector3.ZERO

func seek(target: Vector3):
	var desired = (target - position).normalized() * max_speed
	var steer = desired - velocity
	return steer.clamped(max_force)
