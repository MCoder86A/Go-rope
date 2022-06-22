extends Node


var game_stats_file : File
var current_file_name : String = ""
var cur_access_mode : int

func _ready():
	game_stats_file = File.new()

func _close():
	if game_stats_file.is_open():
		game_stats_file.close()

func _openFile(fileName : String, MODE : int):
	if(game_stats_file.is_open()):
		game_stats_file.close()
		
	game_stats_file.open("user://"+fileName, MODE)
	current_file_name = fileName
	cur_access_mode = MODE
		

func _write(content : String, fileName: String):
	if not game_stats_file.is_open():
		_openFile(fileName, File.WRITE)
		
	if not fileName.match(current_file_name):
		_openFile(fileName, File.WRITE)
		
	if cur_access_mode != File.WRITE:
		_openFile(fileName, File.WRITE)
	
	game_stats_file.store_string(content)
	game_stats_file.close()
	
	
func _read(fileName: String) -> String:
	if not game_stats_file.is_open():
		_openFile(fileName, File.READ)
		
	if not fileName.match(current_file_name):
		_openFile(fileName, File.READ)
		
	if cur_access_mode != File.READ:
		_openFile(fileName, File.READ)
	
	return game_stats_file.\
		get_buffer(game_stats_file.get_len()).\
		get_string_from_utf8()


