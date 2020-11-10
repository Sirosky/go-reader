extends Node


var file_search = FileSearch.new() #Launch file search class
var Dir = Directory.new()
var filter_regex = "(.jpg|.png|.jpeg|.gif|.bmp)"
var filter_regex_zip = "(.zip|.rar|.7z|.gzip|.cbr|.cbz|.tar)"
var tex_sorted = []
var importing_zips = [] #Paths of zips being imported
var importing_complete = -1

onready var Tex = get_node("/root/Main/Tex")
onready var Main = get_node("/root/Main")
onready var Streamer = get_node("../Streamer")
onready var UI = get_node("/root/Main/UI")

var thread = Thread.new()

func _ready():
	pass

func source_load(dir): #Loads and sorts all the source images. Page = page to start on
	#dir = str("C:/" + dir) For some reason, the result from FileDiag doesn't include the Drive
#	print(dir)
	Main.cur_dir = dir

	var search
	
	search = file_search.search_regex_full_path(filter_regex, dir, 1)
	if search.size() > 0:
		var keys = search.keys()
		keys.sort()
		tex_sorted = keys #Sorted in order
	
	var start = 0
	if global.settings["History"].has(Main.cur_dir):
		start = global.settings["History"][Main.cur_dir]
	
	
	if start == 0:
		Streamer.tex_thread_start(0)
		Streamer.page_first_load = 1
	else:
		Streamer.tex_jump(start)
	
	global.Mes.message_send("load complete")

#---------- IMPORT EBOOKS
func source_import_zip_start(source, target, first_run):
	#--- FIRST RUN
	if first_run == 1:
		
		target = str(target + "/" + source.get_file())
		source = ProjectSettings.globalize_path(source)
		
		if !Dir.dir_exists(target): #Create a new folder for the base library
			Dir.make_dir(target)
	
		#Find zips
		var search = file_search.search_regex_full_path(filter_regex_zip, source, 1)
		if search.size()>0:
			importing_zips = search.keys()
			
			if !thread.is_active():
				UI.ProgressBar_toggle()
				UI.ProgressBar.max_value = importing_zips.size()
				thread.start( self, "source_import_zip_load", [importing_zips, target])
			else:
				print("Can't start import. Thread occupied.")
	#--- SECOND RUN OR MORE
	else:
		if !thread.is_active():
			thread.start( self, "source_import_zip_load", [importing_zips, target])

func source_import_zip_load(arr): #importing_zips, target
	var zip_path = str(OS.get_executable_path().get_base_dir() + "\\7z\\7z.exe") #This probably won't work in editor mode
	
	var out_path = ProjectSettings.globalize_path(str(arr[1] + "/" + importing_zips[0].get_file()))
	out_path = out_path.rstrip("." + out_path.get_extension())
#	print(out_path)

	OS.execute(zip_path, ["e", importing_zips[0], "-r", "-y", "-o" + str(out_path)], 1, ["complete"])
	call_deferred("source_import_zip_finished", arr)

func source_import_zip_finished(arr):
	thread.wait_to_finish()
	
	importing_zips.remove(0)
	
	if importing_zips.size() > 0: #We still have more, start allll over again
		UI.ProgressBar.value += 1
		print(UI.ProgressBar.value)
		source_import_zip_start(arr[0], arr[1], 0)
	else: #We are done
		UI.ProgressBar_toggle() #Done! Hide PB again
		global.Mes.message_send("import complete")

#---------- IMPORT LOOSE MANGA/COMICS
func source_import_start(source, target): #Beginning of thread for importing
#	dir = str("C:" + dir) #For some reason, the result from FileDiag doesn't include the Drive
	target = str(target + "/" + source.get_file())
	source = ProjectSettings.globalize_path(source)
	
	if !Dir.dir_exists(target): #Create a new folder for the base library
		Dir.make_dir(target)
	
	var folders = file_search.search_iterate_folder(source, 1)
#	print(source)
#	print(target)
	
	#Make directories for all subfolders
	for i in folders:
		var source_length = source.length()
		var remove_length = i.find(source) + source_length
		i.erase(0, remove_length)
		i = target + i
		if !Dir.dir_exists(i):
			Dir.make_dir(i)
	
	yield(get_tree().create_timer(1), "timeout") 
	if !thread.is_active():
		thread.start( self, "source_import_load", [source, target, folders])
		UI.ProgressBar_toggle()
	else:
		print("Can't start import. Thread occupied.")


func source_import_load(arr): #arr = [source, target, folders]
	var search = file_search.search_regex_full_path(filter_regex, arr[0], 1)
	if search.size()>0:
		#Visual progress
		UI.ProgressBar.max_value = search.size() - 1
		
		var keys = search.keys()
		
		for i in keys: #Put them into target
			var tar
			var source_length = arr[0].length()
			var remove_length = i.find(arr[0]) + source_length
			var base = i
			base.erase(0, remove_length) #Get subfolders
			tar = arr[1] + base #Create the full target directory
			
#			print("i: " + str(i))
#			print("tar: " + str(tar))
			
			Dir.copy(i, tar)
			UI.ProgressBar.value += 1
	
	call_deferred("source_import_finished", arr)

func source_import_finished(arr):
	global.Mes.message_send("import complete")
	thread.wait_to_finish()
	UI.ProgressBar_toggle() #Done! Hide PB again
