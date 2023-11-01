extends CharacterBody3D

class_name Player
#@onready var camera_mount = $cameraMount
@onready var pivot_x = $pivotX
@onready var pivot_y = $pivotX/pivotY
@onready var animation_player = $visuals/mixamo_base/AnimationPlayer
@onready var visuals = $visuals
@onready var grabbingObject: PickableObject = null;
@onready var ray_cast_3d = $pivotX/pivotY/Camera3D/RayCast3D

var mouse_pressed = false
var poited

const SPEED = 3.0
const JUMP_VELOCITY = 5.0
@export var sens = 0.1

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var is_under_attack: bool = false;

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	animation_player.play("idle")


func _physics_process(delta):
	if Input.is_action_just_pressed('ui_cancel'):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (pivot_x.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction and !is_under_attack:
		if animation_player.current_animation != "walking":
			animation_player.play("walking")
			
##		rotation.y = lerp(rotation.y, , 0.1)
#		var target = (position + direction) * 0.5
		
		visuals.look_at(position + direction)
		
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		if animation_player.current_animation != "idle":
			animation_player.play("idle")
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	if !mouse_pressed:
		if grabbingObject: grabbingObject.is_pointed = true
		
	if grabbingObject and mouse_pressed:
		grabbingObject.is_pointed = false
		var actualPosition = grabbingObject.position
		var targetPosition =  $pivotX/pivotY/Camera3D/GrabbingPoint.global_position;
		grabbingObject.position.x = move_toward(actualPosition.x, targetPosition.x, 1)
		grabbingObject.position.y = move_toward(actualPosition.y, targetPosition.y, 1)
		grabbingObject.position.z = move_toward(actualPosition.z, targetPosition.z, 1)
	
	poited = ray_cast_3d.is_colliding()
	
	if ray_cast_3d.get_collider() is PickableObject:
		grabbingObject =  ray_cast_3d.get_collider()
		if mouse_pressed:
			grabbingObject.picked = true
			grabbingObject.is_pointed = false;
			
	if grabbingObject != null:
		grabbingObject.is_pointed = poited
		
	
#	if mouse_pressed:
#		if poited and ray_cast_3d.get_collider() is PickableObject:
#			grabbingObject = ray_cast_3d.get_collider()
#			grabbingObject.picked = true
	
	print(mouse_pressed)
#	print(ray_cast_3d.get_collider())
	move_and_slide()


func _input(event):
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			
			var _x = - event.relative.x * sens
			var _y = - event.relative.y * sens
			
			pivot_x.rotate_y(deg_to_rad(-event.relative.x * sens))
			pivot_y.rotate_x(deg_to_rad(-event.relative.y * sens))
			
			pivot_y.rotation.x = clamp(
				pivot_y.rotation.x,
				deg_to_rad(-40),
				deg_to_rad(40)
			)
			
	if event is InputEventMouseButton:
#		mouse_pressed = event.pressed and event.button_index == MOUSE_BUTTON_LEFT
		
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			mouse_pressed = !mouse_pressed
