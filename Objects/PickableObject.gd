extends RigidBody3D
class_name PickableObject

var typeObjectName: String

var picked: bool = false
#var is_pointed: bool = false
@onready var area = $MeshInstance3D/Area3D
@onready var mesh_highlight: MeshInstance3D = $Highligh/MeshHighlight


func _ready():
	mesh_highlight.visible = false

func _process(delta):
	if picked: 
		mesh_highlight.visible = false;
	$CollisionShape3D.disabled = picked;
	
#	mesh_highlight.visible = is_pointed;
	

func toggle_visibility():
	mesh_highlight.visible = !mesh_highlight.visible


func _on_area_3d_area_entered(area):
	toggle_visibility()


func _on_area_3d_area_exited(area):
	toggle_visibility()
