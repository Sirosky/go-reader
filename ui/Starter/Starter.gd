extends Control

onready var MenuContext = get_node("/root/Main/Popup/MenuContext")
onready var ButLoad = get_node("Margin/VBox/HBox/VBox1/ButLoad")
onready var ButImport = get_node("Margin/VBox/HBox/VBox2/ButImport")
onready var TexAll = get_node("/root/Main/TexAll")

var start_exit = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	rect_position.x = global.window_width/2 - rect_size.x/2
	rect_position.y = global.window_height/2 - rect_size.y/2
	ButLoad.connect("pressed",self,"_on_ButLoad_pressed")
	ButImport.connect("pressed",self,"_on_ButImport_pressed")
	global.Tween.interpolate_property(self, "modulate",Color(1, 1, 1, 0), Color(1, 1, 1, 1), 2, global.Tween.TRANS_CUBIC, global.Tween.EASE_OUT)
	global.Tween.start()


func _on_ButLoad_pressed():
	MenuContext._on_ButLoad_pressed()

func _on_ButImport_pressed():
	MenuContext._on_ButImport_pressed()

func _process(delta):
	if visible == true and TexAll.get_children().size() > 0 and start_exit == 0:
		global.Tween.interpolate_property(self, "modulate",Color(1, 1, 1, 1), Color(1, 1, 1, 0), 1, global.Tween.TRANS_CUBIC, global.Tween.EASE_OUT)
		global.Tween.start()
		start_exit = 1
	
	if modulate == Color(1, 1, 1, 0):
		self.queue_free()
		

