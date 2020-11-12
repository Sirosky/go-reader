extends Node

onready var Camera2D = get_node("/root/Main/Camera2D")
onready var SourceLoader = get_node("../SourceLoader")
onready var TexAll = get_node("/root/Main/TexAll")
onready var MenuContext = get_node("/root/Main/Popup/MenuContext")
onready var Main = get_node("/root/Main")
onready var Core = get_node("/root/Main/Core")
var Tex = "res://core/Tex.tscn"

#These share the same index
var tex_obj = [] #objects
var tex_path = [] #path to texture.
var tex_coord = [] #y coordinate

var page_max = 0 #Most recently loaded page. Pretty much irrelevant if there's a page jump.
var page_cur = 0 #Current page we're looking at
var page_buffer = 5 # How many extra pages to have loaded
var page_buffer_unload = 10 #How many pages before we start unloading their textures. Should be greater than page_buffer
var pages_tracking = [] #Current 
var pages_tracking_temp = []
var page_first_load = 0 #First time loading something a stream
var tex_y_buffer = 24 #Space to leave between pages
var just_jumped = 0 #Temporarily disables auto-loading new pages with page_new after a jump
var jump_buffer_lesser = [] #Order of pages to load less than jumped page
var jump_buffer_greater = [] #Order of pages to load greater than jumped page
var jump_buffer_removed = [] #Pages that have been sent to processing

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
	#---- STREAMING LOGIC
	
	if just_jumped == 0 and tex_obj.size() > 0:
		
<<<<<<< Updated upstream
		#Check down
		var i = page_max + 1 
		if i < page_cur + page_buffer and !thread_processing.has(i) and i <= SourceLoader.tex_sorted.size() - 1:
			if tex_obj.has(i):
				while i < page_cur + page_buffer:
					var skip = 0 #Stop iterating if we encounter an unloaded page
					if tex_obj[i] == Core: #If we jumped and this page had never been initiated
=======
		#-- DOWN
		var i = min(page_cur + 1, SourceLoader.tex_sorted.size() - 1)
		UI.Lab[8].text = str(i)
		if !thread_queue.has(i) and !thread_processing.has(i):
			while i <= page_cur + page_buffer:
				var skip = 0 #Stop iterating if we encounter an unloaded page
				
				if i <= tex_obj.size() -1 :
					if tex_obj[i] == Core and !pages_loaded.has(i) and !thread_processing.has(i): #If we jumped and this page had never been initiated
>>>>>>> Stashed changes
						tex_thread_start(i) #Properly load it now
	#					print("page down: " + str(i))
						skip = 1

					if skip == 0:
						if tex_obj[i].texture == null:
							tex_thread_start(i)
	#						print("page down: " + str(i))
							skip = 1

					if skip ==0:
						i -= 1
					else:
						i = page_cur - page_buffer
			else:
				tex_thread_start(i)
		
		#-- UP
		if page_cur - page_buffer >= 0: #Don't drop below 0
			i = max(page_cur - 1, 0)
			
			while i >= page_cur - page_buffer:
				var skip = 0 #Stop iterating if we encounter an unloaded page
			
				if tex_obj[i] == Core: #If we jumped and this page had never been initiated
					tex_thread_start(i) #Properly load it now
#					print("page up: " + str(i))
					skip = 1
	
				if skip == 0:
					if tex_obj[i].texture == null:
						tex_thread_start(i)
#						print("page up: " + str(i))
						skip = 1
				
				if skip ==0:
					i -= 1
				else:
					i = page_cur - page_buffer - 1
		
		#First load
		if page_max == 0 and page_first_load == 1:
			tex_thread_start(page_cur + 1)
			page_max = 1
	
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
	
	#---- POST BUFFER JUMP LOADING
	var remove = -1
	
	if just_jumped == 1:
		
		#Buffer prior to page
		for i in range(jump_buffer_lesser.size()):
			if thread_queue.has(jump_buffer_lesser[i]):
				remove = i
#				print("jump_buffer_lesser[i]: " + str(jump_buffer_lesser[i]))
#				print("Already processing lesser")
				break
			thread_queue.append(jump_buffer_lesser[i]) #Put in queue if it's not already there
			
		
		#Buffer after page
		remove = -1
		
		for i in range(jump_buffer_greater.size()):
			if thread_queue.has(jump_buffer_greater[i]):
				remove = i
#				print("jump_buffer_greater[i]: " + str(jump_buffer_greater[i]))
#				print("Already processing greater")
				break
			thread_queue.append(jump_buffer_greater[i]) #Put in queue if it's not already there

		#Exit just_jumped mode once we can
		if jump_buffer_greater.size() + jump_buffer_lesser.size() == 0 and jump_buffer_removed.size() > 1:
			just_jumped = 0
#			print("Exiting just_jumped mode")
	


func _input(event):
	pass
	#Next page
#	if event is InputEventMouseButton and event.button_index == BUTTON_MIDDLE and event.pressed and not event.is_echo():
#		if tex_obj[page_cur].texture == null: #Extra emergency loading
#			print("MMB emergency loading: " + str(page_cur))
#			print(tex_obj[page_cur].texture)
#			tex_obj[page_cur].texture = null
#			tex_load(page_cur)
		
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
	pass


func _on_camera_moved():
	#Current page detection
#	pass
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


	
func tex_jump(page): #Used to jump to a specific page
	Main.reset()
	Camera2D.camera_limit_y1 = -9999999
	
	if page >= 0 and page <= SourceLoader.tex_sorted.size() - 1:
		var i = 0
		while i < page + 1:
			tex_obj.append(Core)
			tex_path.append("")
			tex_coord.append(-9999)
			i += 1
		page_cur = page
		just_jumped = 1
		tex_thread_start(page)
		
		#Load some buffer too
		yield(get_tree().create_timer(.5), "timeout")
		
		just_jumped = 1
		i = page - 1
		while i > page - 3:
			if i >= 0:
#				print(i)
				jump_buffer_lesser.append(i)
#				tex_thread_start(i)
			i -= 1

		i = page + 1
		while i < page + 3:
			if i <= SourceLoader.tex_sorted.size() - 1:
				jump_buffer_greater.append(i)
#				tex_thread_start(i)
			i += 1
		
		#Next stage is under _process


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
#			print("thread start processing page: " + str(index))
#			print(str(index) + " " + str(SourceLoader.tex_sorted[index]))
			thread[i].start( self, "tex_thread_load", [index, i])
			thread_processing.append(index)
			var loc = thread_queue.find(index)
			if loc != -1:
				thread_queue.remove(loc)
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
#	print(texture)
	
	call_deferred("tex_thread_finish", arr)
	return texture

func tex_thread_finish(arr): #This takes place on the main thread
	var texture = thread[arr[1]].wait_to_finish()
	
	#-------- CASE A- there has been no jump (might not be necessary anymore, can probably remove)
	if !tex_obj.has(Core):
		page_max = tex_coord.size() - 1 #Check if a Tex for this page exists already
		
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

			tex_obj.append(t)
			tex_path.append(SourceLoader.tex_sorted[arr[0]])
		else: #page already exists
			tex_obj[arr[0]].texture = texture
			tex_obj[arr[0]].rect_position.x = (texture.get_width()/2) * -1
	#		print("loading old page " + str(arr[0]))
	
	#-------- CASE B- there has been a jump
	else:
		page_max = tex_coord.size() - 1 #Check if a Tex for this page exists already
#		print("jump loading")
		var tex_status = tex_obj_is_valid(arr[0])
		
		if tex_status > 0: #New texture, or not propery initiated
			var t = global.scene_load(Tex, TexAll)
			t.texture = texture
			t.page = arr[0]
#			print("t.page: " + str(t.page))
			
			
			#Figure out what Tex we should base our y coordinate on
			var tex_next = tex_obj_is_valid(arr[0] + 1)
			var tex_prev = tex_obj_is_valid(arr[0] - 1)
			
#			print("tex_next: " + str(tex_next))
#			print("tex_prev: " + str(tex_prev))
#			print("tex_status: " + str(tex_status))
			t.rect_position.y = 2500
			
			if tex_coord.size() - 1 == page_cur: #First load after jumping
				t.rect_position.y = 0
			if tex_next == 0: #scrolling up
				t.rect_position.y = tex_obj[arr[0] + 1].rect_position.y - t.rect_size.y - tex_y_buffer
			if tex_prev == 0: #scrolling down
				t.rect_position.y = tex_obj[arr[0] - 1].rect_position.y + tex_obj[arr[0] - 1].rect_size.y + tex_y_buffer
			
			t.rect_position.x = (texture.get_width()/2) * -1
#			print("y pos: " + str(t.rect_position.y))
			
			page_max = tex_coord.size() - 1
			
			match tex_status:
				1: 
					tex_obj.append(t)
					tex_path.append(SourceLoader.tex_sorted[arr[0]])
					tex_coord.append(t.rect_position.y)
				2:
					tex_obj[arr[0]] = t
					tex_path[arr[0]] = SourceLoader.tex_sorted[arr[0]]
					tex_coord[arr[0]] = t.rect_position.y
		else: #Texture exists and is fully initiated
			tex_obj[arr[0]].texture = texture
			tex_obj[arr[0]].rect_position.x = (texture.get_width()/2) * -1
	#		print("loading old page " + str(arr[0]))
	
	#Handle arrays
	var loc = thread_processing.find(arr[0])
	if loc != -1: thread_processing.remove(loc)
		#print("thread_processing removed: " + str(loc))
	loc = jump_buffer_greater.find(arr[0])
	
	#If we just_jumped
	if loc != -1:
#		print("jump_buffer_greater: " + str(loc))
		jump_buffer_greater.remove(loc)
		jump_buffer_removed.append(loc)
	loc = jump_buffer_lesser.find(arr[0])
	if loc != -1:
#		print("jump_buffer_lesser: " + str(loc))
		jump_buffer_lesser.remove(loc)
		jump_buffer_removed.append(loc)
	
	#If this is a first load
	if page_first_load == 1:
		page_first_load = 0
	
#	print("Finished pg: " + str(arr[0]))


func tex_obj_is_valid(index): #Checks if an entry in tex_obj is a properly initiated Tex
	var tex_status = 0 # 0 = everything is good, 1 = completely new, 2 = exists but not initiated, 3 = invalid [ie negative number]
		
	if !tex_obj.size() - 1 >= index: #New
		tex_status = 1
	else:
		if tex_obj[index] == Core: #Existing, but only made for jump
			tex_status = 2
#	
	if index < 0:
		tex_status = 3
##	
#print("index: " + str(index))
#	print("tex_status: " + str(tex_status))
	return tex_status

func reset():
	#Reset all the relevant variables for Streamer
	for i in thread:
		i.wait_to_finish()
	
	tex_obj = [] #objects
	tex_path = [] #path to texture.
	tex_coord = [] #y coordinate
	
	page_max = 0 #Most recently loaded page
	page_cur = 0 #Current page we're looking at	
	pages_tracking = [] #Current 
	pages_tracking_temp = []
	page_first_load = 0
	
	#Threading
	thread_status = [] #values = 1 for active, 0 for inactive
	thread_queue = [] #value = index. Array of stuff the thread needs to load
	thread_processing = [] #Array of indices
	jump_buffer_lesser = [] #Order of pages to load less than jumped page
	jump_buffer_greater = [] #Order of pages to load greater than jumped page
	jump_buffer_removed = [] #Pages that have been sent to processing
