extends Node


var file_search = FileSearch.new() #Launch file search class
var Dir = Directory.new()
var filter_regex = "(.jpg|.png|.jpeg)"
var tex_sorted = []


onready var Tex = get_node("/root/Main/Tex")
onready var Main = get_node("/root/Main")
onready var Streamer = get_node("../Streamer")


func source_load(dir): #Loads and sorts all the source images
	
	dir = str("C:/" + dir) #For some reason, the result from FileDiag doesn't include the Drive
	print(dir)
	Main.cur = 0 #Reset whatever we were reading
	var search
	#OS.shell_open("C:\\Users")
	#OS.shell_open(ProjectSettings.globalize_path("user://"))
	
	#1a- Search loaded directory for importing if necessary
#	if dir != "user://":
#		search = file_search.search_regex_full_path(filter_regex, dir, 1)
#		print(search)
#
#		if search.size()>0:
#			var keys = search.keys()
#
#			for i in keys: #Put them into user://
#				#var image_path = "user://db/anidb/"+str(ani_id)+"/cover.jpg"
#				var n = i.get_file()
#				print(n)
#				Dir.copy(i, str("user://temp/" + str(n)))
#				#print(Dir.copy(dir, str("user://temp/" + str(n))))
#	else:
	#OR 2b- Search library
	search = file_search.search_regex_full_path("", dir, 1)
	if search.size() > 0:
		var keys = search.keys()
		keys.sort()
		tex_sorted = keys #Sorted in order
		
	Streamer.tex_load(0)
	Streamer.tex_load(1)
	Streamer.tex_load(2)
	Streamer.tex_load(3)
	Streamer.tex_load(4)


