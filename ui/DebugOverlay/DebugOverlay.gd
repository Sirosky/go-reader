extends CanvasLayer

var Lab = []
onready var Cam = get_node("../Camera2D")
onready var Streamer = get_node("/root/Main/Core/Streamer")

func _ready():
	for i in $Debug.get_children():
		Lab.append(i)
	
func _process(delta):
#	str(str() + ": " + str())
	Lab[0].text = str(str("Camera coordinates") + ": " + str(Cam.position))
	Lab[1].text = str(str("Current page") + ": " + str(Streamer.page_cur))
	Lab[2].text = str(str("Maximum pages loaded") + ": " + str(Streamer.page_max))
	
	if Streamer.tex_obj.size() > 0:
		Lab[3].text = str(str("Texture for current page") + ": " + str(Streamer.tex_obj[Streamer.page_cur].texture))

	Lab[4].text = str(str("Threads currently processing") + ": " + str(Streamer.thread_processing))
	Lab[5].text = str(str("Thread 1 busy") + ": " + str(Streamer.thread[0].is_active()))
	Lab[6].text = str(str("Thread 2 busy") + ": " + str(Streamer.thread[1].is_active()))
