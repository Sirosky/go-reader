extends Node
#Singleton for general utility

var window_width:int = ProjectSettings.get("display/window/size/width")
var window_height:int = ProjectSettings.get("display/window/size/height")
var mouse_x = 1
var mouse_y = 1
var rng = RandomNumberGenerator.new()

#Nodes for reference
onready var root = get_node("/root")
onready var Camera = get_node("/root/Main/Camera2D")
onready var Main = get_node("/root/Main")
onready var Tween = get_node("/root/Main/Core/Tween")
onready var Mes = get_node("/root/Main/UI/Messenger")

#Settings
var settings_path = "res://settings/settings.json"
var settings = {}

func _ready():
	rng.randomize()
	
func _process(delta):
	window_width = OS.get_window_size().x
	window_height = OS.get_window_size().y
	var res = Camera.get_global_mouse_position()
	mouse_x = res.x
	mouse_y = res.y

#----------- node management

func scene_load(scn_path : String, scn_par : Object): #Load, instance, and add a scene to a parent
	var scn = load(scn_path) #Load scene from resources
	var scn_inst = scn.instance() #Instance scene
	scn_par.add_child(scn_inst) #Get the parent and add it to the scene tree
	return scn_inst
	
func scene_load_par(scn_path : String, scn_par : Object, self_node):
	var scn=load(scn_path) #Load scene from resources
	var scn_inst= scn.instance() #Instance scene
	self_node.scn_par.add_child(scn_inst) #Get the parent and add it to the scene tree
	return scn_inst
	
func scene_instance(scn, scn_par : Object): #Instance an already loaded scene, add to parent
	var scn_inst= scn.instance() #Instance scene
	scn_par.add_child(scn_inst) #Get the parent and add it to the scene tree
	return scn_inst

static func children_delete(node):
#Deletes all child nodes
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()

func directory_list(path):
	var files = [] # create array to hold files
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "": #last file already reached, leave loop
			break
		elif not file.begins_with("."): #check if directory, then add
			files.append(file)
	return files
	
#-----JSON 

func json_read(json_path):
	#Open, read, and load JSON
	#PathJSON e.g. "res://data/test.json"
	var data_file = File.new()
	if data_file.open(json_path, File.READ) != OK:
		print("read error: " + str(json_path))
		return
	var data_text = data_file.get_as_text()
	data_file.close()
	var data_parse = JSON.parse(data_text)
	if data_parse.error != OK:
		print("parse error: " + str(json_path))
		return
	print("parse successful: " + str(json_path))
	#print(data_parse.result)
	
	return data_parse.result

func json_write(json_path, dic):
	#Open, read, and load JSON
	#dic- dictionary to be stored in json
	#PathJSON e.g. "res://data/test.json"
	var data_file = File.new()
	if data_file.open(json_path, File.WRITE) != OK:
		print("read error: " + str(json_path))
		return
	
	data_file.store_line(to_json(dic))
	data_file.close()
	print("write success: " + str(json_path))
