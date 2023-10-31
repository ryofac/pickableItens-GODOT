extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var mainCamera: Camera3D = $MainCamera

var camera_rotation = Vector2(0,0)
var camera_sensivity = 0.01

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;

func _input(event):
	# ESC pressionado:
	if event.is_action_pressed("ui_cancel"):
		var mouse_mode = Input.mouse_mode
		var captured = Input.MOUSE_MODE_CAPTURED
		var released = Input.MOUSE_MODE_VISIBLE
		Input.mouse_mode = captured if mouse_mode == released else released
	
	if event is InputEventMouseMotion:
		var mouse_event = event.relative * camera_sensivity
		camera_look(mouse_event)
		
func camera_look(mouse_movement):
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	camera_rotation += mouse_movement;
#	camera_rotation.y = clamp(camera_rotation.y, deg_to_rad(90), deg_to_rad(180))
	transform.basis = Basis()
	mainCamera.transform.basis = Basis();
	self.rotate_object_local(Vector3(0, 1, 0), -camera_rotation.x)
	mainCamera.rotate_object_local(Vector3(1,0,0), -camera_rotation.y)
	
	
func handle_movement(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_front", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	print(direction)
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

	
	
func _physics_process(delta):
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		return
	handle_movement(delta);

	
