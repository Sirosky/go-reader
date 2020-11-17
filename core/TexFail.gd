extends HBoxContainer

onready var ButOpen = get_node("ButOpen")
onready var ButOpenDir = get_node("ButOpenDir")
var path = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	ButOpen.connect("pressed",self,"_on_ButOpen_pressed")
	ButOpenDir.connect("pressed",self,"_on_ButOpenDir_pressed")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_ButOpen_pressed():
	OS.shell_open(path)

func _on_ButOpenDir_pressed():
	var path_true = path.get_base_dir()
	OS.shell_open(path_true)
