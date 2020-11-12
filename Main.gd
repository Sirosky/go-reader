extends Control

onready var MenuContext = get_node("Popup/MenuContext")
onready var SourceLoader = get_node("Core/SourceLoader")
onready var Streamer = get_node("Core/Streamer")
onready var Debug = get_node("/root/Main/UI/Debug")
onready var UI = get_node("UI")
onready var TexAll = get_node("TexAll")
onready var Camera2D = get_node("Camera2D")
onready var Starter = get_node("UI/Starter")
onready var Welcome = get_node("/root/Main/Popup/Welcome")
onready var ColorRect = get_node("Popup/ColorRect")

var Dir = Directory.new()
var cur_dir = "" #Current directory manga is loaded from

#Options
var read_pages = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	settings_load()

func _input(event):
	#Next page
#	if event is InputEventMouseButton and event.button_index == BUTTON_MIDDLE and event.pressed and not event.is_echo():
#		page_next()

	if event.is_action_pressed("ui_cancel"): #Exit
		settings_save_page()
		yield(get_tree().create_timer(.1), "timeout") 
		get_tree().quit()
	if event.is_action_pressed("ui_debug_overlay"):
		Debug.visible = !Debug.visible
	if event.is_action_pressed("ui_jump"):
		UI.Jump_toggle()
	if event.is_action_pressed("ui_fullscreen"):
		var a = OS.is_window_fullscreen()
		a = !a
		OS.set_window_fullscreen(a)
	if event.is_action_pressed("ui_load"):
		MenuContext._on_ButLoad_pressed()

func reset():
	if TexAll.get_child_count() > 0: #If there's anything loaded prior, reset everything
		Camera2D.position.x = 0
		Camera2D.position.y = OS.get_screen_size().y/2
		Camera2D.camera_limit_y1 = -24
		#Save our progress
		settings_save_page()
	
#		Camera2D.set_zoom(Vector2(1,1))
		global.children_delete(TexAll)
		Streamer.reset()

func settings_reset():
	global.settings["General"] = {}
	global.settings["General"]["first_start"] = false
	global.settings["General"]["autoload"] = true
	global.settings["General"]["autoload_source"] = ""
	global.settings["General"]["fullscreen"] = true
	global.settings["General"]["debug_overlay"] = false
	global.settings["History"] = {}
	global.settings["BG"] = {}
	global.settings["BG"]["color"] = {}
	global.settings["BG"]["color"]["h"] = float(226)/float(360)
	global.settings["BG"]["color"]["s"] = float(60)/float(360)
	global.settings["BG"]["color"]["v"] = float(20)/float(360)
	global.settings["Filter"] = {}
	global.settings["Filter"]["on"] = true
	global.settings["Filter"]["color"] = {}
	global.settings["Filter"]["color"]["h"] = float(226)/float(360)
	global.settings["Filter"]["color"]["s"] = float(60)/float(360)
	global.settings["Filter"]["color"]["v"] = float(20)/float(360)
	global.settings["Filter"]["color"]["a"] = float(20)/float(360)

func settings_load():
	var file_temp = File.new()
	
	if file_temp.file_exists(global.settings_path): #Existing setting
		global.settings = global.json_read(global.settings_path)
		
		set_debug_overlay()
		set_fullscreen()
		set_bg_color(global.settings["BG"]["color"]["h"], global.settings["BG"]["color"]["s"], global.settings["BG"]["color"]["v"])
		
		if global.settings["General"]["autoload"] == true and !global.settings["General"]["autoload_source"] == "" and Dir.dir_exists(global.settings["General"]["autoload_source"]):
			Starter.queue_free()
			SourceLoader.source_load(global.settings["General"]["autoload_source"])
		
	else: #new start
		settings_reset()
		settings_save()
		Welcome.toggle()
		global.settings["General"]["first_start"] = false

func settings_save():
	var settings_path = OS.get_executable_path().get_base_dir() + "\\settings" #Only works when exported.
	#ProjecSettings.globalize_path doesn't work when exported for some dumb reason, so this is the workaround.
	
	if !Dir.dir_exists(settings_path): #Create a new folder for the base library
			Dir.make_dir(settings_path)

	global.json_write(global.settings_path, global.settings)
	
func settings_save_page():
	if cur_dir != "":
		global.settings["History"][cur_dir] = Streamer.page_cur
		global.settings["General"]["autoload_source"] = cur_dir
		settings_save()

#set settings

func set_debug_overlay():
	Debug.visible = global.settings["General"]["debug_overlay"]

func set_fullscreen():
	OS.set_window_fullscreen(global.settings["General"]["fullscreen"])

func set_bg_color(h, s, v):
	VisualServer.set_default_clear_color(Color.from_hsv(h, s, v, 1))

func set_filter_color(h, s, v, a):
	ColorRect.color = Color.from_hsv(h, s, v, a)
