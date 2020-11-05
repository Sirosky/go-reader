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
var tex_y_buffer = 24 #Space to leave between pages

func _ready():
	Camera2D.connect("camera_moved", self, "_on_camera_moved")

func _process(delta):
	pass

func _input(event):
	#Next page
	if event is InputEventMouseButton and event.button_index == BUTTON_MIDDLE and event.pressed and not event.is_echo():
		if page_max < SourceLoader.tex_sorted.size() - 1:
			page_max += 1
			tex_load(page_max)
		
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
					tex_load(i)
				i += 1
		elif pg.page + page_buffer <= SourceLoader.tex_sorted.size(): #New pages
			var i = page_max
			while i < pg.page + page_buffer + 1:
				if i > tex_coord.size() - 1: #This prevents double loading pages on startup
					tex_load(i)
				i += 1
	
	#Scrolling up
	if pg.page < page_cur: 
		if !pages_tracking.has(pg): #Check if this page is now current page
			pages_tracking.append(pg)
		
		#Load previously unloaded pages
		if pg.page - page_buffer >= 0:
			if tex_obj[pg.page - page_buffer].texture == null:
				tex_load(pg.page - page_buffer)

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
		
		var pages_tracking_temp = pages_tracking #For purging old pages
		for i in range(pages_tracking_temp.size() - 1):
			if abs(page_cur - pages_tracking_temp[i].page) > Camera2D.camera_scroll_speed/15:
				pages_tracking.remove(i)
