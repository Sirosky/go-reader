extends Node


var file_search = FileSearch.new() #Launch file search class
var Dir = Directory.new()
var filter_regex = "(.jpg|.png|.jpeg)"
var tex_sorted = []

onready var Tex = get_node("/root/Main/Tex")
onready var Main = get_node("/root/Main")
onready var Streamer = get_node("../Streamer")

var thread = Thread.new()


func source_load(dir): #Loads and sorts all the source images
	#dir = str("C:/" + dir) For some reason, the result from FileDiag doesn't include the Drive
#	print(dir)
	var search
	
	search = file_search.search_regex_full_path(filter_regex, dir, 1)
	if search.size() > 0:
		var keys = search.keys()
		keys.sort()
		tex_sorted = keys #Sorted in order

	Streamer.tex_thread_start(0)
	Streamer.tex_thread_start(1)
	Streamer.tex_thread_start(2)
	Streamer.tex_thread_start(3)
	Streamer.tex_thread_start(4)

func source_import_start(source, target): #Beginning of thread for importing
#	dir = str("C:" + dir) #For some reason, the result from FileDiag doesn't include the Drive
		
	target = str(target + "/" + source.get_file())
	
	if !Dir.dir_exists(target): #Create a new folder for this
		Dir.make_dir(target)
	
	if !thread.is_active():
		thread.start( self, "source_import_load", [source, target])


func source_import_load(arr):
	var search = file_search.search_regex_full_path("", arr[0], 1)

	if search.size()>0:
		var keys = search.keys()

		for i in keys: #Put them into target
			var n = i.get_file()
			var sub
			
			if i.get_base_dir().get_file() == arr[0].get_file(): #No subfolders present at all
				sub = arr[1]
			else: #Subfolder present
				# 2-depth subfolder, ie subfolder within subfolder
				if i.get_base_dir().get_base_dir().get_file() != arr[0].get_file():
					sub = str(arr[1] + "/" + i.get_base_dir().get_base_dir().get_file() + "/" + i.get_base_dir().get_file())
				else: #Only 1-depth subfolder
					sub = str(arr[1] + "/" + i.get_base_dir().get_file())
#				print(i.get_base_dir().get_file()) #Subfolder
#				print(i.get_base_dir().get_base_dir().get_file()) #Subfolder's parent folder
			
			if !Dir.dir_exists(sub): #Create a new folder for this
				Dir.make_dir(sub)

			Dir.copy(i, str(str(sub) + "/" + str(n)))
	
	call_deferred("source_import_finished", arr)

func source_import_finished(arr):
	
	thread.wait_to_finish()
