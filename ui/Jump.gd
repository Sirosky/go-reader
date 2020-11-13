extends Control

onready var SpinBox = get_node("Margin/VBoxContainer/SpinBox")
onready var ButJump = get_node("Margin/VBoxContainer/HBoxContainer/ButJump")
onready var ButCancel = get_node("Margin/VBoxContainer/HBoxContainer/ButCancel")
onready var Streamer = get_node("/root/Main/Core/Streamer")
onready var UI = get_node("../")

# Called when the node enters the scene tree for the first time.
func _ready():
	ButJump.connect("pressed",self,"_on_ButJump_pressed")
	ButCancel.connect("pressed",self,"_on_ButCancel_pressed")

func _process(delta):
	if !str(SpinBox.value).is_valid_integer():
		SpinBox.value = 1

func _input(event):
	if visible == true:
		if event.is_action_pressed("ui_accept"):
			SpinBox.apply()
			_on_ButJump_pressed()


func _on_ButJump_pressed():
	Streamer.tex_jump(max(int(SpinBox.value) - 1, 0))
	SpinBox.value = 1
	SpinBox.get_line_edit().text = "1"
	UI.Jump_toggle()

func _on_ButCancel_pressed():
	UI.Jump_toggle()
