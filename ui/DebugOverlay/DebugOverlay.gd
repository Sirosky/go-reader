extends CanvasLayer

var Lab = []
onready var Cam = get_node("../Camera2D")
onready var SourceLoader = get_node("/root/Main/Core/SourceLoader")
onready var Streamer = get_node("/root/Main/Core/Streamer")
onready var Debug = get_node("Debug") 
onready var ProgressBar = get_node("ProgressBar")
onready var Jump = get_node("Jump")

func _ready():
	#Set up debug
	for i in $Debug.get_children():
		Lab.append(i)
	ProgressBar.rect_position.x = 0
	ProgressBar.rect_position.y = global.window_height - ProgressBar.rect_size.y
	
func _process(delta):
	#Update debugger
#	str(str() + ": " + str())
	Lab[0].text = str(str("Camera coordinates") + ": " + str(Cam.position))
	Lab[1].text = str(str("Current page") + ": " + str(Streamer.page_cur))
	Lab[2].text = str(str("Maximum pages loaded") + ": " + str(Streamer.page_max))
	
#	if Streamer.page_cur <= Streamer.tex_obj.size() and Streamer.tex_obj.size() > 0:
#		Lab[3].text = str(str("Texture for current page") + ": " + str(Streamer.tex_obj[Streamer.page_cur].texture))

	Lab[4].text = str(str("Threads currently processing") + ": " + str(Streamer.thread_processing))
	Lab[5].text = str(str("Thread 1 busy") + ": " + str(Streamer.thread[0].is_active()))
	Lab[6].text = str(str("Thread 2 busy") + ": " + str(Streamer.thread[1].is_active()))
	
	if ProgressBar.modulate == Color(1, 1, 1, 0): #Make it invisible
		ProgressBar.visible = false
	
	if Jump.modulate == Color(1, 1, 1, 0): #Make it invisible
		Jump.visible = false

func ProgressBar_toggle():
	var vis = !ProgressBar.visible
	
	if vis == true:
		ProgressBar.visible = true
		global.Tween.interpolate_property(ProgressBar, "modulate",Color(1, 1, 1, 0), Color(1, 1, 1, .8), 1, global.Tween.TRANS_CUBIC, global.Tween.EASE_OUT)
		global.Tween.start()
	else: #Reset progress bar, make it go away
		global.Tween.interpolate_property(ProgressBar, "modulate",Color(1, 1, 1, .8), Color(1, 1, 1, 0), 1, global.Tween.TRANS_CUBIC, global.Tween.EASE_OUT)
		global.Tween.start()
		ProgressBar.max_value = 100
		ProgressBar.value = 0

func Jump_toggle():
	var vis = !Jump.visible
	
	if vis == true:
		Jump.visible = true
		Jump.rect_position.x = global.window_width/2 - Jump.rect_size.x/2
		Jump.rect_position.y = global.window_height/2 - Jump.rect_size.y/2
		global.Tween.interpolate_property(Jump, "modulate",Color(1, 1, 1, 0), Color(1, 1, 1, .8), 1, global.Tween.TRANS_CUBIC, global.Tween.EASE_OUT)
		global.Tween.start()
		
		if SourceLoader.tex_sorted.size() > 0:
			Jump.SpinBox.max_value = SourceLoader.tex_sorted.size() - 1
		else:
			Jump.SpinBox.max_value = 0
		
	else: #Reset progress bar, make it go away
		global.Tween.interpolate_property(Jump, "modulate",Color(1, 1, 1, .8), Color(1, 1, 1, 0), 1, global.Tween.TRANS_CUBIC, global.Tween.EASE_OUT)
		global.Tween.start()
		Jump.SpinBox.value = 0
