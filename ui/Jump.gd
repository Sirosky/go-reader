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


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_ButJump_pressed():
	Streamer.tex_jump(int(SpinBox.value))
	UI.Jump_toggle()

func _on_ButCancel_pressed():
	UI.Jump_toggle()
