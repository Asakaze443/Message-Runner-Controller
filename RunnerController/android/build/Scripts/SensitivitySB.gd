extends SpinBox

onready var spin_box = get_node(".")

# Called when the node enters the scene tree for the first time.
func _ready():
	var line_edit = spin_box.get_line_edit()
	line_edit.virtual_keyboard_enabled = false
	
