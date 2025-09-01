class_name ChemElement extends Resource


@export var name: String
@export var atomic_number: int
@export var chem_symbol: String
@export var mass: int
@export_multiline var description: String = ""

@export_enum(
	"metais alcalinos",
	"metais alcalinoterrosos",
	"outros metais",
	"metais de transição",
	"lantanídeos",
	"actinídeos",
	"semimetais",
	"não metais",
	"halogênios",
	"gases nobres",
	"desconhecidas"
) var category: String #SRC = https://upload.wikimedia.org/wikipedia/commons/b/bf/Periodic_table_large-pt_BR.svg thank me later dumbass

@export var texture: Texture2D

@export var max_stack_size: int
## Item ID.
#var id: int = IDGen.generate_id()

@export var other_attributes: Dictionary[String, Variant]
