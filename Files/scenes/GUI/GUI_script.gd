extends Control

@onready var game_controller: Node = $".."

@export var pause_screen: Control

var is_game_paused: bool = false

func _ready() -> void:
	game_controller.change_gui_scene("res://Files/scenes/GUI/Menus/MainMenu/MainMenu.tscn")
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if pause_screen:
		pause_screen.pause_mode = Node.PROCESS_MODE_WHEN_PAUSED
		pause_screen.visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		_toggle_pause()

func _toggle_pause() -> void:
	is_game_paused = not is_game_paused
	get_tree().paused = is_game_paused
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if is_game_paused else Input.MOUSE_MODE_CAPTURED)
	if pause_screen:
		pause_screen.visible = is_game_paused
	print("Is game paused? %s" % is_game_paused)
