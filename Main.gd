extends Control

onready var MenuContext = get_node("MenuContext")
onready var SourceLoader = get_node("Core/SourceLoader")
onready var Streamer = get_node("Core/Streamer")
onready var Debug = get_node("/root/Main/UI/Debug")
onready var UI = get_node("UI")
onready var TexAll = get_node("TexAll")
onready var Camera2D = get_node("Camera2D")

var cur_dir = "" #Current directory manga is loaded from

#Options
var read_pages = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	#Next page
#	if event is InputEventMouseButton and event.button_index == BUTTON_MIDDLE and event.pressed and not event.is_echo():
#		page_next()

	if event.is_action_pressed("ui_cancel"): #Exit
		get_tree().quit() 
	if event.is_action_pressed("ui_debug_overlay"):
		Debug.visible = !Debug.visible
	if event.is_action_pressed("ui_jump"):
		UI.Jump_toggle()
	if event.is_action_pressed("ui_fullscreen"):
		var a = OS.is_window_fullscreen()
		a = !a
		OS.set_window_fullscreen(a)

func reset():
	if TexAll.get_child_count() > 0: #If there's anything loaded prior, reset everything
		Camera2D.position.x = 0
		Camera2D.position.y = global.window_height/2
		Camera2D.camera_limit_y1 = -24
#		Camera2D.set_zoom(Vector2(1,1))
		global.children_delete(TexAll)
		Streamer.reset()
