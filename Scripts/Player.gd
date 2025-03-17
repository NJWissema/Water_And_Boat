class_name Player extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const SWIM_VELOCITY = 2.0

var primaryPlayer : bool = false
@export var playerName: String
@export var playerID: int

@onready var neck := $Neck
@onready var camera := $Neck/Camera3D
@onready var label := $Label3D
@onready var robot := $"3DGodotRobot"
@onready var robotAnimation := $"3DGodotRobot/AnimationPlayer"
@onready var Synchronizer := $MultiplayerSynchronizer

var is_swimming: bool = false
var is_floating: bool = false

func _ready():
	#Synchronizer.set_multiplayer_authority(str(name).to_int())
	#camera.current = Synchronizer.get_multiplayer_authority() == multiplayer.get_unique_id()
	
	camera.current = true
	label.text = str(playerName)

func _unhandled_input(event):
	#if Synchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
	if true:
		#Handle mouse state
		if event is InputEventMouseButton:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		elif event.is_action_pressed("ui_cancel"):
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
			
		#Handle character camera movement
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			if event is InputEventMouseMotion:
				neck.rotate_y (-event.relative.x * PlayerVariables.mouse_sensitivity)
				robot.rotate_y (-event.relative.x * PlayerVariables.mouse_sensitivity)
				camera.rotate_x (-event.relative.y * PlayerVariables.mouse_sensitivity)
				#Clamp camera rotation
				camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-85), deg_to_rad(85))

func _physics_process(delta):
	#if Synchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
	if true:
		# Get the input direction and handle the movement/deceleration.
		
			
		if is_swimming:
			# Handle jump.
			if Input.is_action_just_pressed("player_up"):
				if is_floating:
					velocity.y = JUMP_VELOCITY
				else:
					velocity.y = SWIM_VELOCITY
			# Get the input direction and handle the movement/deceleration.
			var input_dir = Input.get_vector("player_left", "player_right", "player_forward", "player_back")
			var direction = (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
			if direction:
				velocity.x = direction.x * SPEED
				velocity.z = direction.z * SPEED
				robotAnimation.play("Run")
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
				velocity.z = move_toward(velocity.z, 0, SPEED)
				robotAnimation.play("Idle")

		else:
			# Add the gravity.
			if not is_on_floor():
				velocity += get_gravity() * delta
				robotAnimation.play("Fall")

			# Handle jump.
			if Input.is_action_just_pressed("player_up") and is_on_floor():
				velocity.y = JUMP_VELOCITY
				robotAnimation.play("Jump")
			
			var input_dir = Input.get_vector("player_left", "player_right", "player_forward", "player_back")
			var direction = (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
			# Get the input direction and handle the movement/deceleration.
			if direction:
				velocity.x = direction.x * SPEED
				velocity.z = direction.z * SPEED
				robotAnimation.play("Run")
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
				velocity.z = move_toward(velocity.z, 0, SPEED)
				robotAnimation.play("Idle")

		move_and_slide()
