extends Control


func _ready():
	rect_size.x = OS.get_screen_size().x
	rect_size.y = OS.get_screen_size().y


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
