extends TextureRect


onready var Vis = get_node("VisibilityNotifier2D")
onready var Streamer = get_node("/root/Main/Core/Streamer")
onready var Camera2D = get_node("/root/Main/Camera2D")
onready var Core = get_node("/root/Main/Core")

var page = 0 #The page this texture is loaded for

# Called when the node enters the scene tree for the first time.
func _ready():
	Vis.connect("screen_exited", self, "_on_screen_exited")
	Vis.connect("screen_entered", self, "_on_screen_entered")

func _process(delta):
	
	Vis.rect = Rect2( 0, 0, rect_size.x, rect_size.y)
	
	if abs(Streamer.page_cur - page) > Streamer.page_buffer_unload and texture != null: #Unload ourself
		Streamer.tex_obj[page] = Core
		if Streamer.pages_tracking.has(self):
			Streamer.pages_tracking.erase(self)
		if Streamer.pages_loaded.has(page):
			Streamer.pages_loaded.erase(page)
		self.queue_free()
#		print(str(page) + " unloaded")

	#Fallback in case a page failed to load. Emergency loading!
	if Vis.is_on_screen() and texture == null and !Streamer.thread_queue.has(page) and !Streamer.thread_processing.has(page):
		Streamer.tex_thread_start(page)
#		print("emergency load: " + str(page))
	
	if !Vis.is_on_screen() and Streamer.pages_tracking.has(page): #Remove us from tracking
		if abs(Streamer.page_cur - page) > Camera2D.camera_scroll_speed/10:
			Streamer.pages_tracking.remove(Streamer.pages_tracking.find(page))

func _on_screen_exited():
	pass

func _on_screen_entered():
	#Fancy fade in
	global.Tween.interpolate_property(self, "modulate",Color(1, 1, 1, 0), Color(1, 1, 1, 1), .5, global.Tween.TRANS_CUBIC, global.Tween.EASE_OUT)
	global.Tween.start()
	
	if !Streamer.pages_tracking.has(self):
		Streamer.pages_tracking.append(self)
	Streamer.page_new(self)
#	Streamer.page_cur = page


