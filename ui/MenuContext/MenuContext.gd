extends MarginContainer

onready var ButLoad = get_node("VBox/ButLoad")
onready var ButImport = get_node("VBox/ButImport")
onready var ButDirectory = get_node("VBox/ButDirectory")
onready var FileDiag = get_node("../FileDialog")
onready var Core = get_node("/root/Main/Core")
onready var SourceLoader = get_node("/root/Main/Core/SourceLoader")
onready var Streamer = get_node("/root/Main/Core/Streamer")
onready var Popup = get_node("../")
onready var Camera2D = get_node("/root/Main/Camera2D")
onready var TexAll = get_node("/root/Main/TexAll")
onready var Panel = get_node("Panel")
onready var Main = get_node("/root/Main")

var FileDiag_mode = 0 #0 = Load, 1 = Import select import source, 2 = Import select import location
var import_source = "" #Path that is to be imported
var import_timer = 0
var Dir = Directory.new()

func _ready():
	ButLoad.connect("pressed",self,"_on_ButLoad_pressed")
	ButImport.connect("pressed",self,"_on_ButImport_pressed")
	ButDirectory.connect("pressed",self,"_on_ButDirectory_pressed")
	
	FileDiag.connect("confirmed",self,"_on_confirmed")
	FileDiag.connect("file_selected",self,"_on_file_selected")
	FileDiag.mode = 2 #Open directory mode
	FileDiag.access = 2 #Can access all directories
	

func _process(delta):
	Panel.rect_size.x = rect_size.x
	Panel.rect_size.y = rect_size.y
	Panel.rect_position.x = 0
	Panel.rect_position.y = 0
	
	if import_timer > 0: #Begin stage 2 of importing
		import_timer -= 1
		if import_timer == 0:
			FileDiag_show()
			FileDiag.access = 1 #Only user data
			FileDiag_mode = 2
			
			var tar = ProjectSettings.globalize_path("user://library")
			if !Dir.dir_exists(tar): #Making sure library exists
				Dir.make_dir(tar)
			
			FileDiag.current_dir = tar
			FileDiag.window_title = "Select the import target location"

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


func _on_ButLoad_pressed(): #Prepare to load a manga from our library
	hide()
	FileDiag_show()
	FileDiag.mode = 2 #Open directory mode
	FileDiag.access = 1
	FileDiag_mode = 0
	FileDiag.current_dir = ProjectSettings.globalize_path("user://")
	FileDiag.window_title = "Load from library"

func _on_ButImport_pressed(): #Import a manga
	hide()
	FileDiag_show()
	FileDiag.access = 2 #Filesystem
	FileDiag_mode = 1
	FileDiag.window_title = "Load an import source"

func _on_ButDirectory_pressed():
	hide()
	OS.shell_open(ProjectSettings.globalize_path("user://library"))

func _on_confirmed():
	if FileDiag_mode == 0: #Load new manga from library
		Main.settings_save_page()
		Main.reset()
		Main.cur_dir = ProjectSettings.globalize_path(FileDiag.current_dir)
		SourceLoader.source_load(ProjectSettings.globalize_path(FileDiag.current_dir))
	
	if FileDiag_mode == 1: #Import source
		import_source = ProjectSettings.globalize_path(FileDiag.current_dir)
		import_timer = 20 #Slight delay before showing FileDiag again
	
	if FileDiag_mode == 2: #Select import target
		SourceLoader.source_import_start(import_source, ProjectSettings.globalize_path(FileDiag.current_dir))
	

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

func FileDiag_show():
	FileDiag.popup()
	FileDiag.rect_position.x = global.window_width/2 - FileDiag.rect_size.x/2
	FileDiag.rect_position.y = global.window_height/2 - FileDiag.rect_size.y/2
