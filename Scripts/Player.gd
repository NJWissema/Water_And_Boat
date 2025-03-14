class_name Player extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

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
		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta
			robotAnimation.play("Fall")

		# Handle jump.
		if Input.is_action_just_pressed("Player_up") and is_on_floor():
			velocity.y = JUMP_VELOCITY
			robotAnimation.play("Jump")

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_dir = Input.get_vector("Player_left", "Player_right", "Player_forward", "Player_back")
		var direction = (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
			robotAnimation.play("Run")
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
			robotAnimation.play("Idle")

		move_and_slide()
