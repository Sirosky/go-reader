extends Control

onready var Main = get_node("/root/Main")

onready var General = get_node("Margin/VBox/Body/Right/General")
onready var Background = get_node("Margin/VBox/Body/Right/Background")
onready var Filter = get_node("Margin/VBox/Body/Right/Filter")
onready var Floater = get_node("Floater")

#Left submenu
onready var ButGeneral = get_node("Margin/VBox/Body/Left/ButGeneral")
onready var ButBG = get_node("Margin/VBox/Body/Left/ButBG")
onready var ButFilter = get_node("Margin/VBox/Body/Left/ButFilter")

#General
onready var CheckAuto = get_node("Margin/VBox/Body/Right/General/CheckAuto")
onready var CheckFull = get_node("Margin/VBox/Body/Right/General/CheckFull")
onready var CheckDebug = get_node("Margin/VBox/Body/Right/General/CheckDebug")

#BG
onready var LabelH = get_node("Margin/VBox/Body/Right/Background/H3")
onready var SliderH = get_node("Margin/VBox/Body/Right/Background/H2")
onready var LabelS = get_node("Margin/VBox/Body/Right/Background/S3")
onready var SliderS = get_node("Margin/VBox/Body/Right/Background/S2")
onready var LabelV = get_node("Margin/VBox/Body/Right/Background/V3")
onready var SliderV = get_node("Margin/VBox/Body/Right/Background/V2")

#Filter
onready var CheckFilter = get_node("Margin/VBox/Body/Right/Filter/CheckFilter")
onready var FLabelH = get_node("Margin/VBox/Body/Right/Filter/H3")
onready var FSliderH = get_node("Margin/VBox/Body/Right/Filter/H2")
onready var FLabelS = get_node("Margin/VBox/Body/Right/Filter/S3")
onready var FSliderS = get_node("Margin/VBox/Body/Right/Filter/S2")
onready var FLabelV = get_node("Margin/VBox/Body/Right/Filter/V3")
onready var FSliderV = get_node("Margin/VBox/Body/Right/Filter/V2")
onready var FLabelA = get_node("Margin/VBox/Body/Right/Filter/A3")
onready var FSliderA = get_node("Margin/VBox/Body/Right/Filter/A2")

onready var ButClose = get_node("Margin/VBox/Accept/ButClose")

func _ready():
	CheckAuto.rect_scale.x = .8
	CheckAuto.rect_scale.y = .8
	CheckAuto.rect_position.y += 4
	CheckFull.rect_scale.x = .8
	CheckFull.rect_scale.y = .8
	CheckFull.rect_position.y += 4
	CheckDebug.rect_scale.x = .8
	CheckDebug.rect_scale.y = .8
	CheckDebug.rect_position.y += 4
	CheckFilter.rect_scale.x = .8
	CheckFilter.rect_scale.y = .8
	CheckFilter.rect_position.y += 4
	
	CheckAuto.connect("pressed", self, "_on_CheckAuto_updated")
	CheckFull.connect("pressed", self, "_on_CheckFull_updated")
	CheckDebug.connect("pressed", self, "_on_CheckDebug_updated")
	CheckFilter.connect("pressed", self, "_on_CheckFilter_updated")
	
	ButGeneral.connect("pressed", self, "_on_Left_updated", [0])
	ButBG.connect("pressed", self, "_on_Left_updated", [1])
	ButFilter.connect("pressed", self, "_on_Left_updated", [2])
	ButClose.connect("pressed", self, "hide")
	SliderH.connect("value_changed", self, "_on_BGColor_updated", [SliderH])
	SliderS.connect("value_changed", self, "_on_BGColor_updated", [SliderS])
	SliderV.connect("value_changed", self, "_on_BGColor_updated", [SliderV])
	FSliderH.connect("value_changed", self, "_on_FilterColor_updated", [FSliderH])
	FSliderS.connect("value_changed", self, "_on_FilterColor_updated", [FSliderS])
	FSliderV.connect("value_changed", self, "_on_FilterColor_updated", [FSliderV])
	FSliderA.connect("value_changed", self, "_on_FilterColor_updated", [FSliderA])
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if modulate == Color(1, 1, 1, 0) and visible == true:
		visible = false
	
	if Background.visible == true:
		LabelH.text = str(SliderH.value)
		LabelS.text = str(SliderS.value)
		LabelV.text = str(SliderV.value)
	
	if Filter.visible == true:
		FLabelH.text = str(FSliderH.value)
		FLabelS.text = str(FSliderS.value)
		FLabelV.text = str(FSliderV.value)
		FLabelA.text = str(FSliderA.value)

func _on_CheckAuto_updated():
	global.settings["General"]["autoload"] = !global.settings["General"]["autoload"]
	Main.settings_save()
	
func _on_CheckFull_updated():
	global.settings["General"]["fullscreen"] = !global.settings["General"]["fullscreen"]
	Main.set_fullscreen()
	Main.settings_save()

func _on_CheckDebug_updated():
	global.settings["General"]["debug_overlay"] = !global.settings["General"]["debug_overlay"]
	Main.set_debug_overlay()
	Main.settings_save()

func _on_CheckFilter_updated():
	global.settings["Filter"]["on"] = !global.settings["Filter"]["on"]
	Main.set_filter()
	Main.settings_save()

func _on_BGColor_updated(value , obj):
	match obj:
		SliderH:
			global.settings["BG"]["color"]["h"] = SliderH.value
		SliderS:
			global.settings["BG"]["color"]["s"] = SliderS.value
		SliderV:
			global.settings["BG"]["color"]["v"] = SliderV.value
	
	Main.set_bg_color(SliderH.value, SliderS.value, SliderV.value)
	Main.settings_save()

func _on_FilterColor_updated(value, obj):
	match obj:
		FSliderH:
			global.settings["Filter"]["color"]["h"] = FSliderH.value
		FSliderS:
			global.settings["Filter"]["color"]["s"] = FSliderS.value
		FSliderV:
			global.settings["Filter"]["color"]["v"] = FSliderV.value
		FSliderA:
			global.settings["Filter"]["color"]["a"] = FSliderA.value
	
	Main.set_filter_color(FSliderH.value, FSliderS.value, FSliderV.value, FSliderA.value)
	Main.settings_save()


func _on_Left_updated(arr): #Left hand tab menu
	General.visible = false
	Background.visible = false
	Filter.visible = false
	match arr:
		0:
			General.visible = true
		1:
			Background.visible = true
		2:
			Filter.visible = true

func show():
	visible = true
	global.Tween.interpolate_property(self, "modulate",Color(1, 1, 1, 0), Color(1, 1, 1, .9), .5, global.Tween.TRANS_CUBIC, global.Tween.EASE_OUT)
	global.Tween.start()
	
	CheckAuto.pressed = global.settings["General"]["autoload"]
	CheckFull.pressed = global.settings["General"]["fullscreen"]
	CheckDebug.pressed = global.settings["General"]["debug_overlay"]
	CheckFilter.pressed = global.settings["Filter"]["on"]
	
	SliderH.value = global.settings["BG"]["color"]["h"]
	SliderS.value = global.settings["BG"]["color"]["s"]
	SliderV.value = global.settings["BG"]["color"]["v"]
	
	FSliderH.value = global.settings["Filter"]["color"]["h"]
	FSliderS.value = global.settings["Filter"]["color"]["s"]
	FSliderV.value = global.settings["Filter"]["color"]["v"]
	FSliderA.value = global.settings["Filter"]["color"]["a"]
	
	
	rect_position.x = OS.get_screen_size().x/2 - rect_size.x/2
	rect_position.y = OS.get_screen_size().y/2 - rect_size.y/2
	General.visible = true
	Background.visible = false

func hide():
	global.Tween.interpolate_property(self, "modulate",Color(1, 1, 1, 0.9), Color(1, 1, 1, 0), .5, global.Tween.TRANS_CUBIC, global.Tween.EASE_OUT)
	global.Tween.start()
	global.Mes.message_send("settings saved")
