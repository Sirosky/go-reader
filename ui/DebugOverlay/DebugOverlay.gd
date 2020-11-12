extends CanvasLayer

var Lab = []
onready var Cam = get_node("../Camera2D")
onready var Main = get_node("/root/Main")
onready var SourceLoader = get_node("/root/Main/Core/SourceLoader")
onready var Streamer = get_node("/root/Main/Core/Streamer")
onready var Debug = get_node("Debug") 
onready var ProgressBar = get_node("ProgressBar")
onready var Jump = get_node("Jump")
onready var LabelPage = get_node("LabelPage")

func _ready():
	#Set up debug
	for i in $Debug.get_children():
		Lab.append(i)
	ProgressBar.rect_position.x = 0
	ProgressBar.rect_position.y = OS.get_screen_size().y - ProgressBar.rect_size.y
	LabelPage.rect_position.x = OS.get_screen_size().x - LabelPage.rect_size.x - 8
	LabelPage.rect_position.y = OS.get_screen_size().y - LabelPage.rect_size.y - 8
	global.Tween.interpolate_property(LabelPage, "modulate",Color(1, 1, 1, 0), Color(1, 1, 1, .8), 1, global.Tween.TRANS_CUBIC, global.Tween.EASE_OUT)
	global.Tween.start()
	
func _process(delta):
	#Update debugger
#	str(str() + ": " + str())
	Lab[0].text = str(str("Camera coordinates") + ": " + str(Cam.position))
	Lab[1].text = str(str("Current page") + ": " + str(Streamer.page_cur))
	Lab[2].text = str(str("Maximum pages loaded") + ": " + str(Streamer.page_max))
	
	Lab[3].text = str(str("Pages tracking") + ": " + str(Streamer.pages_tracking))
	

	Lab[3].text = str(str("Current pages loaded") + ": " + str(Streamer.pages_loaded))

	Lab[4].text = str(str("Threads currently processing") + ": " + str(Streamer.thread_processing))
	Lab[5].text = str(str("Thread 1 busy") + ": " + str(Streamer.thread[0].is_active()))
#	Lab[6].text = str(str("Thread 2 busy") + ": " + str(Streamer.thread[1].is_active()))
	Lab[7].text = str(str("Thread queue") + ": " + str(Streamer.thread_queue))
	
	if ProgressBar.modulate == Color(1, 1, 1, 0): #Make it invisible
		ProgressBar.visible = false
	
	if Jump.modulate == Color(1, 1, 1, 0): #Make it invisible
		Jump.visible = false
	
	LabelPage.rect_position.x = OS.get_screen_size().x - LabelPage.rect_size.x - 8
	if Main.cur_dir != "":
		LabelPage.text = str(str(Streamer.page_cur + 1) + " of " + str(SourceLoader.tex_sorted.size()))
	else:
		LabelPage.text = "n/a"
	

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
		Jump.rect_position.x = OS.get_screen_size().x/2 - Jump.rect_size.x/2
		Jump.rect_position.y = OS.get_screen_size().y/2 - Jump.rect_size.y/2
		global.Tween.interpolate_property(Jump, "modulate",Color(1, 1, 1, 0), Color(1, 1, 1, .9), 1, global.Tween.TRANS_CUBIC, global.Tween.EASE_OUT)
		global.Tween.start()
		
		if SourceLoader.tex_sorted.size() > 0:
			Jump.SpinBox.max_value = SourceLoader.tex_sorted.size() - 1
		else:
			Jump.SpinBox.max_value = 0
		
	else: #Reset progress bar, make it go away
		global.Tween.interpolate_property(Jump, "modulate",Color(1, 1, 1, .9), Color(1, 1, 1, 0), 1, global.Tween.TRANS_CUBIC, global.Tween.EASE_OUT)
		global.Tween.start()
		Jump.SpinBox.value = 0
