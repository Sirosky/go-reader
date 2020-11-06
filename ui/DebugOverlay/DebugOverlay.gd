extends CanvasLayer

var Lab = []
onready var Cam = get_node("../Camera2D")
onready var Streamer = get_node("/root/Main/Core/Streamer")

func _ready():
	for i in $VBoxContainer.get_children():
		Lab.append(i)
	
func _process(delta):
	Lab[0].text = str(Cam.position)
	Lab[1].text = str(Streamer.page_cur)
	Lab[2].text = str(Streamer.page_max)
	
	if Streamer.tex_obj.size() > 0:
		Lab[3].text = str(Streamer.tex_obj[Streamer.page_cur].texture)

	Lab[4].text = str(Streamer.thread_processing)
