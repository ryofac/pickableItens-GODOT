extends Node

var picked_object: PickableObject = null;

signal objectPicked(object);
signal objectDropped();

func setPickedObject(pickedObject):
	self.picked_object = pickedObject;
	if pickedObject:
		print("TO SEGURANDO PORRAAA")
		objectPicked.emit(pickedObject)
	else:
		print("Soltei a bolinha")
		objectDropped.emit()
		

