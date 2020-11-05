extends TextureRect


onready var Vis = get_node("VisibilityNotifier2D")
onready var Streamer = get_node("/root/Main/Core/Streamer")

var page = 0 #The page this texture is loaded for

# Called when the node enters the scene tree for the first time.
func _ready():
	Vis.connect("screen_exited", self, "_on_screen_exited")
	Vis.connect("screen_entered", self, "_on_screen_entered")

func _process(delta):
	Vis.rect = Rect2( 0, 0, rect_size.x, rect_size.y)
	
	if abs(Streamer.page_cur - page) > Streamer.page_buffer_unload and texture != null: #Unload ourself
		texture = null
#		print(str(page) + " unloaded")

func _on_screen_exited():
	pass

func _on_screen_entered():
	Streamer.page_new(self)


