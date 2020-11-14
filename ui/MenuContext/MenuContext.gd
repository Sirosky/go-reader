extends MarginContainer

onready var ButLoad = get_node("Margin/VBox/ButLoad")
onready var ButImport = get_node("Margin/VBox/ButImport")
onready var ButImportZIP = get_node("Margin/VBox/ButImportZIP")
onready var ButDirectory = get_node("Margin/VBox/ButDirectory")
onready var ButSettings = get_node("Margin/VBox/ButSettings")
onready var ButJump = get_node("Margin/VBox/ButJump")
onready var ButCenter = get_node("Margin/VBox/ButCenter")
onready var ButExit = get_node("Margin/VBox/ButExit")

onready var FileDiag = get_node("../FileDialog")
onready var Core = get_node("/root/Main/Core")
onready var SourceLoader = get_node("/root/Main/Core/SourceLoader")
onready var Streamer = get_node("/root/Main/Core/Streamer")
onready var Popup = get_node("../")
onready var Camera2D = get_node("/root/Main/Camera2D")
onready var TexAll = get_node("/root/Main/TexAll")
onready var Panel = get_node("Panel")
onready var Main = get_node("/root/Main")
onready var UI = get_node("/root/Main/UI")
onready var Settings = get_node("/root/Main/Popup/Settings")

var FileDiag_mode = 0 #0 = Load, 1 = Import select import source, 2 = Import select import location
var import_source = "" #Path that is to be imported
var import_timer = 0
var Dir = Directory.new()

func _ready():
	ButLoad.connect("pressed",self,"_on_ButLoad_pressed")
	ButImport.connect("pressed",self,"_on_ButImport_pressed")
	ButDirectory.connect("pressed",self,"_on_ButDirectory_pressed")
	ButSettings.connect("pressed",self,"_on_ButSettings_pressed")
	ButImportZIP.connect("pressed",self,"_on_ButImportZIP_pressed")
	ButJump.connect("pressed",self,"_on_ButJump_pressed")
	ButCenter.connect("pressed",self,"_on_ButCenter_pressed")
	ButExit.connect("pressed",self,"_on_ButExit_pressed")
	
	FileDiag.connect("confirmed",self,"_on_confirmed")
	FileDiag.connect("file_selected",self,"_on_file_selected")
	FileDiag.mode = 2 #Open directory mode
	FileDiag.access = 2 #Can access all directories
	
	#Button hotkey hint (same code is in show(), this is just for setup)
	var LPar = ButLoad
	var L = LPar.get_node("Label")
	L.text = InputMap.get_action_list("ui_load")[0].as_text()
	L.rect_position.x = rect_size.x - L.rect_size.x - 16
	L.rect_position.y = 3
	LPar = ButImportZIP
	L = LPar.get_node("Label")
	L.text = InputMap.get_action_list("ui_import_zip")[0].as_text()
	L.rect_position.x = rect_size.x - L.rect_size.x - 16
	L.rect_position.y = 3
	LPar = ButImport
	L = LPar.get_node("Label")
	L.text = InputMap.get_action_list("ui_import")[0].as_text()
	L.rect_position.x = rect_size.x - L.rect_size.x - 16
	L.rect_position.y = 3
	LPar = ButDirectory
	L = LPar.get_node("Label")
	L.text = InputMap.get_action_list("ui_directory")[0].as_text()
	L.rect_position.x = rect_size.x - L.rect_size.x - 16
	L.rect_position.y = 3
	LPar = ButSettings
	L = LPar.get_node("Label")
	L.text = InputMap.get_action_list("ui_settings")[0].as_text()
	L.rect_position.x = rect_size.x - L.rect_size.x - 16
	L.rect_position.y = 3
	LPar = ButJump
	L = LPar.get_node("Label")
	L.text = InputMap.get_action_list("ui_jump")[0].as_text()
	L.rect_position.x = rect_size.x - L.rect_size.x - 16
	L.rect_position.y = 3
	LPar = ButExit
	L = LPar.get_node("Label")
	L.text = InputMap.get_action_list("ui_cancel")[0].as_text()
	L.rect_position.x = rect_size.x - L.rect_size.x - 16
	L.rect_position.y = 3
	LPar = ButCenter
	L = LPar.get_node("Label")
	L.text = InputMap.get_action_list("ui_center")[0].as_text()
	L.rect_position.x = rect_size.x - L.rect_size.x - 16
	L.rect_position.y = 3
	

func _process(delta):
	rect_size.x = 300
	Panel.rect_size = rect_size
	Panel.rect_position = Vector2(0, 0)
	
	if import_timer > 0: #Begin stage 2 of importing
		import_timer -= 1
		if import_timer == 0:
			if FileDiag_mode == 1: #Importing loose
				FileDiag_mode = 2
			if FileDiag_mode == 4: #Importing zip
				FileDiag_mode = 5
			
			FileDiag_show()
			FileDiag.access = 1 #Only user data
			
			
			var tar = ProjectSettings.globalize_path("user://library")
			if !Dir.dir_exists(tar): #Making sure library exists
				Dir.make_dir(tar)
			
			FileDiag.current_dir = tar
			FileDiag.window_title = "Select the import target location"


func _input(event):
	if event is InputEventMouseButton:
		#Show context menu
		if event.button_index == BUTTON_RIGHT and event.pressed and not event.is_echo():
			show()
		#Hide context menu
		if event.button_index == BUTTON_LEFT and event.pressed and not event.is_echo() and\
		mouse_in_rect(rect_position.x, rect_position.y, rect_position.x + rect_size.x, rect_position.y + rect_size.y) == false:
			hide()


func _on_ButLoad_pressed(): #Prepare to load a manga from our library
	hide()
	FileDiag_show()
	FileDiag.mode = 2 #Open directory mode
	FileDiag.access = 1
	FileDiag_mode = 0
	FileDiag.current_dir = ProjectSettings.globalize_path("user://library")
	FileDiag.window_title = "Load from library"

func _on_ButImport_pressed(): #Import a manga
	hide()
	FileDiag_show()
	FileDiag.access = 2 #Filesystem
	FileDiag_mode = 1
	FileDiag.window_title = "Load an import source"

func _on_ButImportZIP_pressed():
	FileDiag_show()
	FileDiag.access = 2 #Filesystem
	FileDiag_mode = 4
	FileDiag.window_title = "Load the folder with .CBRs, .CBZs,. ZIPs, etc."
	hide()

func _on_ButDirectory_pressed():
	hide()
	OS.shell_open(ProjectSettings.globalize_path("user://library"))


func _on_ButJump_pressed():
	hide()
	UI.Jump_toggle()

func _on_ButSettings_pressed():
	hide()
	Settings.show()

func _on_ButCenter_pressed():
	hide()
	Camera2D.position.x = 0

func _on_ButExit_pressed():
	hide()
	Main.settings_save_page()
	yield(get_tree().create_timer(.1), "timeout") 
	get_tree().quit()

func _on_confirmed():
	if FileDiag_mode == 0: #Load new manga from library
		Main.settings_save_page()
		Main.reset()
		Main.cur_dir = ProjectSettings.globalize_path(FileDiag.current_dir)
		SourceLoader.source_load(ProjectSettings.globalize_path(FileDiag.current_dir))
	
	if FileDiag_mode == 1: #Import loose source
		import_source = ProjectSettings.globalize_path(FileDiag.current_dir)
		import_timer = 20 #Slight delay before showing FileDiag again
		
	if FileDiag_mode == 4: #Import in zip form
		import_source = ProjectSettings.globalize_path(FileDiag.current_dir)
		import_timer = 20 #Slight delay before showing FileDiag again
	
	if FileDiag_mode == 2: #Select loose import target, begin importing
		SourceLoader.source_import_start(import_source, ProjectSettings.globalize_path(FileDiag.current_dir))

	if FileDiag_mode == 5: #Select zip import target, begin importing
		SourceLoader.source_import_zip_start(import_source, ProjectSettings.globalize_path(FileDiag.current_dir), 1)

func show():
	visible = true
	rect_position.x = get_viewport().get_mouse_position().x
	rect_position.y = get_viewport().get_mouse_position().y
	
	#Button hotkey hint
	var LPar = ButLoad
	var L = LPar.get_node("Label")
	L.text = InputMap.get_action_list("ui_load")[0].as_text()
	L.rect_position.x = rect_size.x - L.rect_size.x - 16
	L.rect_position.y = 3
	LPar = ButImportZIP
	L = LPar.get_node("Label")
	L.text = InputMap.get_action_list("ui_import_zip")[0].as_text()
	L.rect_position.x = rect_size.x - L.rect_size.x - 16
	L.rect_position.y = 3
	LPar = ButImport
	L = LPar.get_node("Label")
	L.text = InputMap.get_action_list("ui_import")[0].as_text()
	L.rect_position.x = rect_size.x - L.rect_size.x - 16
	L.rect_position.y = 3
	LPar = ButDirectory
	L = LPar.get_node("Label")
	L.text = InputMap.get_action_list("ui_directory")[0].as_text()
	L.rect_position.x = rect_size.x - L.rect_size.x - 16
	L.rect_position.y = 3
	LPar = ButSettings
	L = LPar.get_node("Label")
	L.text = InputMap.get_action_list("ui_settings")[0].as_text()
	L.rect_position.x = rect_size.x - L.rect_size.x - 16
	L.rect_position.y = 3
	LPar = ButJump
	L = LPar.get_node("Label")
	L.text = InputMap.get_action_list("ui_jump")[0].as_text()
	L.rect_position.x = rect_size.x - L.rect_size.x - 16
	L.rect_position.y = 3
	LPar = ButExit
	L = LPar.get_node("Label")
	L.text = InputMap.get_action_list("ui_cancel")[0].as_text()
	L.rect_position.x = rect_size.x - L.rect_size.x - 16
	L.rect_position.y = 3
	LPar = ButCenter
	L = LPar.get_node("Label")
	L.text = InputMap.get_action_list("ui_center")[0].as_text()
	L.rect_position.x = rect_size.x - L.rect_size.x - 16
	L.rect_position.y = 3

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
	FileDiag.rect_position.x = OS.get_screen_size().x/2 - FileDiag.rect_size.x/2
	FileDiag.rect_position.y = OS.get_screen_size().y/2 - FileDiag.rect_size.y/2
