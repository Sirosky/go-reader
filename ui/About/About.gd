extends PanelContainer

onready var ButClose = get_node("MarginContainer/VBox/ButClose")

# Called when the node enters the scene tree for the first time.
func _ready():
	ButClose.connect("pressed", self, "toggle")

func _process(delta):
	if modulate == Color(1, 1, 1, 0) and visible == true:
		visible = false

func toggle():
	
	var vis = !visible
	
	if vis == true:
		visible = true
		rect_position.x = OS.get_screen_size().x/2 - rect_size.x/2
		rect_position.y = OS.get_screen_size().y/2 - rect_size.y/2
		global.Tween.interpolate_property(self, "modulate",Color(1, 1, 1, 0), Color(1, 1, 1, .9), .5, global.Tween.TRANS_CUBIC, global.Tween.EASE_OUT)
		global.Tween.start()
	else: #Reset progress bar, make it go away
		global.Tween.interpolate_property(self, "modulate",Color(1, 1, 1, .9), Color(1, 1, 1, 0), .5, global.Tween.TRANS_CUBIC, global.Tween.EASE_OUT)
		global.Tween.start()
