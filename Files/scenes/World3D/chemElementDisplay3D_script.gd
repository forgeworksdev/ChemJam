class_name ChemElementDisplay3D extends AnimatableBody3D

@onready var atomic_number_mesh: MeshInstance3D = $Mesh/AtomicNumberMesh
@onready var chem_symbol_mesh: MeshInstance3D = $Mesh/ChemSymbolMesh
@onready var name_mesh: MeshInstance3D = $Mesh/NameMesh
@onready var mass_mesh: MeshInstance3D = $Mesh/MassMesh

@export var rotate: bool = false
@export_range(0.0, 100.0, 0.1) var rotation_speed : int = 10

@export var chem_element: ChemElement

func _ready() -> void:
	atomic_number_mesh.mesh.text = str(chem_element.atomic_number)
	chem_symbol_mesh.mesh.text = chem_element.chem_symbol
	name_mesh.mesh.text = chem_element.name
	mass_mesh.mesh.text = str(chem_element.mass)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if rotate:
		rotate_y(deg_to_rad(rotation_speed * 10 * delta))
