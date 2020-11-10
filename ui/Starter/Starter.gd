extends Control

onready var MenuContext = get_node("/root/Main/Popup/MenuContext")
onready var ButLoad = get_node("Margin/VBox/HBox/VBox1/ButLoad")
onready var ButImportZIP = get_node("Margin/VBox/HBox/VBox3/ButImportZIP")
onready var ButAbout = get_node("Margin/VBox/HBox2/VBox2/ButAbout")
onready var ButImport = get_node("Margin/VBox/HBox/VBox2/ButImport")
onready var ButSettings = get_node("Margin/VBox/HBox2/VBox/ButSettings")
onready var TexAll = get_node("/root/Main/TexAll")
onready var About = get_node("/root/Main/Popup/About")

#Icons are at 50% opacity, with white -> black gradient at 90 degrees @ 30% opacity, 128x128

func _ready():
	ButLoad.connect("pressed",self,"_on_ButLoad_pressed")
	ButImport.connect("pressed",self,"_on_ButImport_pressed")
	ButSettings.connect("pressed",self,"_on_ButSettings_pressed")
	ButImportZIP.connect("pressed",self,"_on_ButImportZIP_pressed")
	ButAbout.connect("pressed",self,"_on_ButAbout_pressed")

func _process(delta):
	if modulate == Color(1, 1, 1, 0) and visible == true:
		visible = false
	
	if TexAll.get_children().size() == 0 and visible == false:
		show()
	
	if visible == true and TexAll.get_children().size() > 0 and modulate == Color(1, 1, 1, .9):
		hide()

func hide():
	global.Tween.interpolate_property(self, "modulate",Color(1, 1, 1, .9), Color(1, 1, 1, 0), .5, global.Tween.TRANS_CUBIC, global.Tween.EASE_OUT)
	global.Tween.start()

func show():
	visible = true
	rect_position.x = OS.get_screen_size().x/2 - rect_size.x/2
	rect_position.y = OS.get_screen_size().y/2 - rect_size.y/2
	global.Tween.interpolate_property(self, "modulate",Color(1, 1, 1, 0), Color(1, 1, 1, .9), .5, global.Tween.TRANS_CUBIC, global.Tween.EASE_OUT)
	global.Tween.start()



func _on_ButLoad_pressed():
	MenuContext._on_ButLoad_pressed()

func _on_ButImport_pressed():
	MenuContext._on_ButImport_pressed()
	
func _on_ButSettings_pressed():
	MenuContext._on_ButSettings_pressed()

func _on_ButImportZIP_pressed():
	MenuContext._on_ButImportZIP_pressed()

func _on_ButAbout_pressed():
	About.toggle()

