extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5


@onready var mainCamera = $Camera


var camera_rotation = Vector2(0,0)
var camera_sensivity = 0.001

#Variaveis de controle
var grabbing: bool = false
var hasTarget: bool = false

var grabbingObject: PickableObject = null
var pointedObject: PickableObject = null
var pointedArea: PlacedArea = null

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
	
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if grabbing:
#				if pointedObject as PlacedArea:
				if pointedArea:
					if pointedArea.typeAreaName == grabbingObject.typeObjectName:
						place_object()
				else:
					drop_object()
				
			if pointedObject as PickableObject:
				grab_object() 

func camera_look(mouse_movement):
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	camera_rotation += mouse_movement;
#	camera_rotation.y = clamp(camera_rotation.y, deg_to_rad(90), deg_to_rad(180))
	transform.basis = Basis()
	mainCamera.transform.basis = Basis();
	self.rotate_object_local(Vector3(0, 1, 0), -camera_rotation.x)
	mainCamera.rotate_object_local(Vector3(1,0,0), -camera_rotation.y)
#	mainCamera.rotation.x = clamp(mainCamera.rotation.x, deg_to_rad(-40), deg_to_rad(60))
	
	
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
	
	if grabbing:
#		grabbingObject.is_pointed = false
		var targetPosition = $Camera/MainCamera/Area3D/GrabbingPointer.global_transform;
		grabbingObject.update_target_position(targetPosition)

func place_object(): 
	var target = pointedArea.get_node("Marker3D").global_transform # Coleta a posição e rotação exata da area selecionada
	grabbingObject.update_target_position(target) # Atualiza a posição na qual o objeto vai se aproximar a cada loop na process

	grabbingObject.positioned = true # Define que o objeto está posicionado
	grabbingObject.picked = false # Define que o objeto não está sendo segurado pelo player
	grabbingObject = null # Define que não existe mais um objeto sendo segurado
	grabbing = false
	Global.setPickedObject(grabbingObject)
	
func drop_object():
	grabbingObject.picked = false
	grabbingObject.apply_central_force((global_transform.basis * Vector3.FORWARD) * 300)
	grabbingObject = null
	grabbing = false
	Global.setPickedObject(grabbingObject)
	
func grab_object():
	grabbingObject = pointedObject;
	grabbingObject.picked = true
	grabbingObject.positioned = false
	grabbing = true
	Global.setPickedObject(grabbingObject)
func _on_area_3d_body_entered(body):
	print(body)
	if body is PickableObject:
		hasTarget = true
		pointedObject = body;

		
func _on_area_3d_body_exited(body):
	if body is PickableObject:
		hasTarget = false
		pointedObject = null

func _on_area_3d_area_entered(area):
	if area.is_in_group("placed_area"):
		pointedArea = area.get_parent();
		


func _on_area_3d_area_exited(area):
	if area.is_in_group("placed_area"):
		pointedArea = null
