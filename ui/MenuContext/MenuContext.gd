extends VBoxContainer

onready var ButLoad = get_node("ButLoad")
onready var FileDiag = get_node("../FileDialog")
onready var Core = get_node("/root/Main/Core")
onready var SourceLoader = get_node("/root/Main/Core/SourceLoader")
onready var Streamer = get_node("/root/Main/Core/Streamer")
onready var Popup = get_node("../")
onready var Camera2D = get_node("/root/Main/Camera2D")
onready var TexAll = get_node("/root/Main/TexAll")
onready var DebugOverlay = get_node("/root/Main/DebugOverlay")

var Streamer_path = "res://core/Streamer.tscn"

func _ready():
	ButLoad.connect("pressed",self,"_on_ButLoad_pressed")
	
	FileDiag.connect("confirmed",self,"_on_confirmed")
	FileDiag.connect("file_selected",self,"_on_file_selected")
	FileDiag.mode = 2 #Open directory mode
	FileDiag.access = 2
	FileDiag.current_dir = ProjectSettings.globalize_path("user://")
	FileDiag.rect_position.x = global.window_width/2 - FileDiag.rect_size.x/2
	FileDiag.rect_position.y = global.window_height/2 - FileDiag.rect_size.y/2

func _input(event):
	if event is InputEventMouseButton:
		#Show context menu
		if event.button_index == BUTTON_RIGHT and event.pressed and not event.is_echo():
			visible = true
			rect_position.x = get_viewport().get_mouse_position().x
			rect_position.y = get_viewport().get_mouse_position().y
		#Hide context menu
		if event.button_index == BUTTON_LEFT and event.pressed and not event.is_echo() and\
		mouse_in_rect(rect_position.x, rect_position.y, rect_position.x + rect_size.x, rect_position.y + rect_size.y) == false:
			
			visible = false


func _on_ButLoad_pressed():
	hide()
	FileDiag.popup()
	FileDiag.rect_position.x = global.window_width/2 - FileDiag.rect_size.x/2
	FileDiag.rect_position.y = global.window_height/2 - FileDiag.rect_size.y/2

func _on_confirmed(): #Load new manga
	#If there's anything loaded prior, reset everything
	if TexAll.get_child_count() > 0:
		Camera2D.position.x = 0
		Camera2D.position.y = global.window_height/2
		Camera2D.set_zoom(Vector2(1,1))
		global.children_delete(TexAll)
		Streamer_reset()
	
	SourceLoader.source_load(ProjectSettings.globalize_path(FileDiag.current_dir))

func hide(): #Hides context menu
	visible = false

func mouse_in_rect(x1, y1, x2, y2):
	#x1, y1 = top left coordinates of rect. x2, y2 = bottom right
	var mouse_x = get_viewport().get_mouse_position().x
	var mouse_y = get_viewport().get_mouse_position().y
		
	if mouse_x > x1 and mouse_y > y1 and mouse_x < x2 and mouse_y < y2:
		return true
	else:
		return false

func Streamer_reset():
	#Reset all the relevant variables for Streamer
	for i in Streamer.thread:
		i.wait_to_finish()
	
	Streamer.tex_obj = [] #objects
	Streamer.tex_path = [] #path to texture.
	Streamer.tex_coord = [] #y coordinate
	
	Streamer.page_max = 0 #Most recently loaded page
	Streamer.page_cur = 0 #Current page we're looking at	
	Streamer.pages_tracking = [] #Current 
	Streamer.pages_tracking_temp = []
	
	#Threading
	Streamer.thread_status = [] #values = 1 for active, 0 for inactive
	Streamer.thread_queue = [] #value = index. Array of stuff the thread needs to load
	Streamer.thread_processing = [] #Array of indices
