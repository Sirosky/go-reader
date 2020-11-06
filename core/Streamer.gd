extends Node

onready var Camera2D = get_node("/root/Main/Camera2D")
onready var SourceLoader = get_node("../SourceLoader")
onready var TexAll = get_node("/root/Main/TexAll")
var Tex = "res://core/Tex.tscn"

#These share the same index
var tex_obj = [] #objects
var tex_path = [] #path to texture.
var tex_coord = [] #y coordinate

var page_max = 0 #Most recently loaded page
var page_cur = 0 #Current page we're looking at
var page_buffer = 5 # How many extra pages to have loaded
var page_buffer_unload = 10 #How many pages before we start unloading their textures. Should be greater than page_buffer
var pages_tracking = [] #Current 
var pages_tracking_temp = []
var tex_y_buffer = 24 #Space to leave between pages

#Threading
var thread = []
var thread_status = [] #values = 1 for active, 0 for inactive
var thread_queue = [] #value = index. Array of stuff the thread needs to load
var thread_processing = [] #Array of indices

func _ready():
	Camera2D.connect("camera_moved", self, "_on_camera_moved")
	thread.append(Thread.new())
	thread.append(Thread.new())

func _process(delta):
	#Background loading
	#Check if thread has more work to do
	if thread_queue.size() > 0:
		
		thread_status = []
	
		for i in range(thread.size()):
			thread_status.append(int(thread[i].is_active()))
			
		if thread_status.has(0): #Have at least one free thread
#			print("Starting from queue")
			tex_thread_start(thread_queue[0])
			thread_queue.remove(0) #Remove from queue


func _input(event):
	#Next page
	if event is InputEventMouseButton and event.button_index == BUTTON_MIDDLE and event.pressed and not event.is_echo():
		if tex_obj[page_cur].texture == null: #Extra emergency loading
			print("MMB emergency loading: " + str(page_cur))
			print(tex_obj[page_cur].texture)
			tex_obj[page_cur].texture = null
			tex_load(page_cur)
		
func tex_load(index): #Loads from tex_sorted. Does not use thread, unlike tex_thread_start.
	#More reliable but greatly impacts fps
	if index >= SourceLoader.tex_sorted.size() or index < 0:
		return #Cancel, this exceeds array size
	if SourceLoader.tex_sorted[index].get_extension() == "jpg" or SourceLoader.tex_sorted[index].get_extension() == "png": #Make sure we have the right file
		#print(SourceLoader.tex_sorted[index])
		var image = Image.new()
		var err = image.load(SourceLoader.tex_sorted[index])
		
		if err != OK:
			print("Error loading thumb- "+ str(err))
		
		var image_w = image.get_width()
		var image_h = image.get_height()
		var texture = ImageTexture.new()
		
		texture.create_from_image(image,7)
		
		#Check if a Tex for this page exists already
		page_max = tex_coord.size() - 1
		if index >= page_max: #Loading a new page
			
			var t = global.scene_load(Tex, TexAll)
			t.texture = texture
			t.page = tex_coord.size()
			
			if tex_coord.size() == 0: #Completely new stream, page 0
				t.rect_position.y = 0
				t.rect_position.x = (texture.get_width()/2) * -1
				tex_coord.append(0)
			else: #Stream already exists
				t.rect_position.y = tex_obj[tex_coord.size()-1].rect_position.y + tex_obj[tex_coord.size()-1].rect_size.y + tex_y_buffer
				t.rect_position.x = (texture.get_width()/2) * -1
				tex_coord.append(t.rect_position.y)
			page_max = tex_coord.size() - 1
			
#			print(index)
			tex_obj.append(t)
			tex_path.append(SourceLoader.tex_sorted[index])
		else: #page already exists
			tex_obj[index].texture = texture
			tex_obj[index].rect_position.x = (texture.get_width()/2) * -1
#			print("loading old page " + str(index))

func page_new(pg): #New page showed up
#	print("new pg: " + str(pg.page))
	#Scrolling down
	if pg.page > page_cur: 
		if !pages_tracking.has(pg): #Check if this page is now current page
			pages_tracking.append(pg)
			
		
		if pg.page + page_buffer <= page_max: #This is for previously loaded pages (scrolling up, then scrolling down)
			var i = pg.page
			while i < pg.page + page_buffer:
				if tex_obj[i].texture == null: #Load previously seen pages as needed
					tex_thread_start(i)
				i += 1
		elif pg.page + page_buffer <= SourceLoader.tex_sorted.size(): #New pages
			var i = page_max
			while i < pg.page + page_buffer:
				if i > tex_coord.size() - 1: #This prevents double loading pages on startup
					tex_thread_start(i)
				i += 1
	
	#Scrolling up
	if pg.page < page_cur: 
		if !pages_tracking.has(pg): #Check if this page is now current page
			pages_tracking.append(pg)
		
		#Load previously unloaded pages
		if pg.page - page_buffer >= 0:
			if tex_obj[pg.page - page_buffer].texture == null:
				tex_thread_start(pg.page - page_buffer)

func _on_camera_moved():
	#Current page detection
	if pages_tracking.size() > 0: 
		
		var lowest_diff: float = 99999
		var result = 0
		for i in pages_tracking: #Check which page is closest to the center
			var check_1 = float(abs(i.rect_position.y - Camera2D.position.y))
			var check_2 = float(abs(i.rect_position.y + (i.rect_size.y) - Camera2D.position.y))
			var res = min(check_1, check_2)
			
			if res < lowest_diff:
				lowest_diff = res
				result = i.page
		
		page_cur = result
		
		pages_tracking_temp = pages_tracking #For purging old pages
		
		if pages_tracking_temp.size() > 0:
			for i in range(pages_tracking_temp.size() - 2):
				if abs(page_cur - pages_tracking_temp[i].page) > Camera2D.camera_scroll_speed/10:
					pages_tracking.remove(i)
	
	
		
		

#---------- THREADING

func tex_thread_start(index):
	#Make sure this isn't already being processed
	if thread_processing.has(index):
#		print("A thread is already processing this page: " + str(index))
		return
	
	thread_status = []
	
	for i in range(thread.size()):
		thread_status.append(int(thread[i].is_active()))
	
	#Pick a thread if one is available.
	for i in range(thread_status.size()): 
		if thread_status[i] == 0: #Not busy
#			print("thread selected: " + str(i))
#			print("thread processing page: " + str(index))
			print(str(index) + " " + str(SourceLoader.tex_sorted[index]))
			thread[i].start( self, "tex_thread_load", [index, i])
			thread_processing.append(index)
			return
			
	
	#No eligible threads? Add into queue. Thank you, come again
	if !thread_queue.has(index):
		thread_queue.append(index)
#		print(thread_queue)
		

func tex_thread_load(arr): #value 0 = index, 1 = thread ID
	var image = Image.new()
	var err = image.load(SourceLoader.tex_sorted[arr[0]])
	
	if err != OK:
		print("Error loading thumb- "+ str(err))
	
	var image_w = image.get_width()
	var image_h = image.get_height()
	var texture = ImageTexture.new()
	
	texture.create_from_image(image,7)
	
	call_deferred("tex_thread_finish", arr)
	return texture

func tex_thread_finish(arr): #This takes place on the main thread
	var texture = thread[arr[1]].wait_to_finish()
	
	#Check if a Tex for this page exists already
	page_max = tex_coord.size() - 1
	if arr[0] >= page_max: #Loading a new page
		
		var t = global.scene_load(Tex, TexAll)
		t.texture = texture
		t.page = tex_coord.size()
		
		if tex_coord.size() == 0: #Completely new stream, page 0
			t.rect_position.y = 0
			t.rect_position.x = (texture.get_width()/2) * -1
			tex_coord.append(0)
		else: #Stream already exists
			t.rect_position.y = tex_obj[tex_coord.size()-1].rect_position.y + tex_obj[tex_coord.size()-1].rect_size.y + tex_y_buffer
			t.rect_position.x = (texture.get_width()/2) * -1
			tex_coord.append(t.rect_position.y)
		page_max = tex_coord.size() - 1
		
#			print(index)
		tex_obj.append(t)
		tex_path.append(SourceLoader.tex_sorted[arr[0]])
	else: #page already exists
		tex_obj[arr[0]].texture = texture
		tex_obj[arr[0]].rect_position.x = (texture.get_width()/2) * -1
#		print("loading old page " + str(arr[0]))
	
	#Clear from processing array
	var loc = thread_processing.find(arr[0])
	if loc != -1:
		thread_processing.remove(loc)
		#print("thread_processing removed: " + str(loc))

