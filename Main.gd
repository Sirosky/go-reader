extends Control

onready var MenuContext = get_node("MenuContext")
onready var SourceLoader = get_node("Core/SourceLoader")
onready var Debug = get_node("/root/Main/DebugOverlay/Debug")

var cur = 0 #Current file loaded

#Options
var read_pages = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	#Next page
#	if event is InputEventMouseButton and event.button_index == BUTTON_MIDDLE and event.pressed and not event.is_echo():
#		page_next()
	
	#Exit
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit() 
	if event.is_action_pressed("ui_debug_overlay"):
		Debug.visible = !Debug.visible
	if event.is_action_pressed("ui_fullscreen"):
		var a = OS.is_window_fullscreen()
		a = !a
		OS.set_window_fullscreen(a)
