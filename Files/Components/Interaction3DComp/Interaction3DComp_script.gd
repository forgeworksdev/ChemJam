class_name Interaction3DComponent extends Node

@export var enabled: bool

@export var raycast: RayCast3D
@export var action_name: String
@export var group_name: String

func _physics_process(_delta: float) -> void:
	if enabled:
		handle_interactions()

func handle_interactions():
	if not raycast.is_colliding():
		return

	var object = raycast.get_collider()

	if not object.is_in_group(group_name):
		return

	#can_interact_signal.emit() #FIXME Implement signals in the future

	if Input.is_action_just_pressed(action_name):
		if object.has_method("interact"):
			object.interact(self)
