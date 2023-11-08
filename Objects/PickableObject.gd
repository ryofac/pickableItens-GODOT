extends RigidBody3D
class_name PickableObject

@export var typeObjectName: String

var picked: bool = false
var positioned: bool = false

#var is_pointed: bool = false
@onready var area = $Area3D
@onready var mesh_highlight: MeshInstance3D = $Highligh/MeshHighlight

var targetPosition: Transform3D

signal itemDropped(item);

func _ready():
	mesh_highlight.visible = false

func _process(delta):
	# Só vai ficar frizado se for pegado ou posicionado
	freeze = picked || positioned;
	if picked:
		itemDropped.emit(self);
		mesh_highlight.visible = false
		update_position(0.5)
		
	
	if positioned:
		update_position(0.1)
	
	$CollisionShape3D.disabled = picked;

	
	
#	mesh_highlight.visible = is_pointed;
	

func update_position(move_speed):
	var actualPosition = self.global_transform
	global_transform = actualPosition.interpolate_with(targetPosition, move_speed)

func update_target_position(newPosition: Transform3D):
	targetPosition = newPosition

func toggle_visibility():
	mesh_highlight.visible = !mesh_highlight.visible

# Se o player estiver olhando: highlight
func _on_area_3d_area_entered(area):
	if area.is_in_group("RayCastPlayer"):
		mesh_highlight.visible = true

# Se o player parar de olhar: encerrar highlight
func _on_area_3d_area_exited(area):
	if area.is_in_group("RayCastPlayer"):
		mesh_highlight.visible = false
	
