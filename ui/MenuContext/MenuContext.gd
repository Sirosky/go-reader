extends VBoxContainer

onready var ButLoad = get_node("ButLoad")
onready var FileDiag = get_node("../FileDialog")
onready var SourceLoader = get_node("/root/Main/Core/SourceLoader")
onready var Popup = get_node("../")

func _ready():
	ButLoad.connect("pressed",self,"_on_ButLoad_pressed")
	
	FileDiag.connect("confirmed",self,"_on_confirmed")
	FileDiag.connect("file_selected",self,"_on_file_selected")
	FileDiag.mode = 2 #Open directory mode
	FileDiag.access = 2
	FileDiag.current_dir = ProjectSettings.globalize_path("user://")

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT and event.pressed and not event.is_echo():
			visible = true
			rect_position.x = get_viewport().get_mouse_position().x
			rect_position.y = get_viewport().get_mouse_position().y
		if event.button_index == BUTTON_LEFT and event.pressed and not event.is_echo() and\
		mouse_in_rect(rect_position.x, rect_position.y, rect_position.x + rect_size.x, rect_position.y + rect_size.y) == false:
			
			visible = false


func _on_ButLoad_pressed():
	hide()
	FileDiag.popup()

func _on_confirmed():
	SourceLoader.source_load(FileDiag.current_path)

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
