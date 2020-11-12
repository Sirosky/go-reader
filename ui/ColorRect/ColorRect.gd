extends ColorRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	_resize()


func _resize():
	rect_position = Vector2(0, 0)
	rect_size = OS.get_window_size()
