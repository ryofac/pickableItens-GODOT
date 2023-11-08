extends Node3D

class_name PlacedArea

@export var typeAreaName: String
var currentBody: PickableObject

func  _ready():
	Global.objectPicked.connect(Callable(make_visible))
	Global.objectDropped.connect(Callable(make_invisible))
	visible = false
	
func _on_area_3d_area_entered(area):
	if !currentBody:
		if area.is_in_group('pickable_object'):
			var body: PickableObject = area.get_parent()
			print("A logica esta funcional e eu deveria estar invisivel")
			if !body.picked:
				currentBody = body
				visible = false
			
func make_visible(item: PickableObject):
	if item:
		if item.typeObjectName == typeAreaName and !currentBody:
			print("somos do mesmo tipo")
			visible = true;
			
func make_invisible():
	print("Estou ficando invisivel")
	visible = false;

func _on_area_3d_area_exited(area):
	var body = area.get_parent();
	if body is PickableObject and body == currentBody:
		currentBody = null
#		visible = true
