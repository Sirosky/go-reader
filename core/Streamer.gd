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
var thread = Thread.new()
var thread_queue = [] #value = index. Array of stuff the thread needs to load

func _ready():
	Camera2D.connect("camera_moved", self, "_on_camera_moved")

func _process(delta):
	#Background loading
	pass
#	if queue_loading.size() > 0:
#		var index_remove = [] #Array of indices to remove from queue_loading and queue_index
#
#		for i in range(queue_loading.size()):
#			if queue.is_ready(queue_loading[i]): #done
#				tex_thread_start_fancy_2(queue.get_resource(queue_loading[i]), queue_index[i])
#				index_remove.append(i)
#
#		if index_remove.size() > 0:
#			for i in index_remove:
#				queue_loading.remove(i)
#				queue_index.remove(i)

func _input(event):
	#Next page
	if event is InputEventMouseButton and event.button_index == BUTTON_MIDDLE and event.pressed and not event.is_echo():
		if tex_obj[page_cur].texture == null: #Extra emergency loading
			tex_thread_start(page_cur)
		
func tex_load(index): #Loads from tex_sorted
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
			while i < pg.page + page_buffer + 1:
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
	if (thread.is_active()):
		#Thank you, come again
		thread_queue.append(index)
#		print("thread busy")
		return
	else:
#		print("thread starting: " + str(index))
		thread.start( self, "tex_thread_load", index)
	

func tex_thread_load(index):
	var image = Image.new()
	var err = image.load(SourceLoader.tex_sorted[index])
	
	if err != OK:
		print("Error loading thumb- "+ str(err))
	
	var image_w = image.get_width()
	var image_h = image.get_height()
	var texture = ImageTexture.new()
	
	texture.create_from_image(image,7)
	
	call_deferred("tex_thread_finish", index)
	return texture

func tex_thread_finish(index): #This takes place on the main thread
	var texture = thread.wait_to_finish()
	
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
	
	#Once we're done processing, remove entry in thread_queue if necessary
	if thread_queue.has(index):
		var ind = thread_queue.find(index)
#		print("removed: " + str(ind))
		thread_queue.remove(ind)
	
	#Check if thread has more work to do
	if thread_queue.size() > 0 and !thread.is_active():
#		print("preparing to process: " + str(thread_queue[0]))
		tex_thread_start(thread_queue[0])
		
