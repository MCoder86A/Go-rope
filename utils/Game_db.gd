extends "res://utils/FileManager.gd"

var db : Dictionary

func _is_db_exist(db_name: String) -> bool:
	if db.has(db_name):
		return true

	var f = File.new()
	if f.file_exists("user://"+db_name):
		return true

	return false
	

func _create_db(db_name: String, content: String):
	if _is_db_exist(db_name):
		return

	_openFile(db_name, File.WRITE)
	_write(content, db_name)
	

#Open db_name and store the result in db dict
func _open_db(db_name: String):
	if not db.has(db_name):
		var db_raw = _read(db_name)
		var json_result: JSONParseResult = JSON.parse(db_raw)
		if json_result.error == OK:
			db[db_name] = json_result.result

func _save_db(db_name: String):
	if not db.has(db_name):
		return
	var db_raw = JSON.print(db[db_name])
	_write(db_raw, db_name)

func _update(db_name: String, key: String, val):
	if not db.has(db_name):
		_open_db(db_name)
		
	db[db_name][key] = val
	
func _get_db(db_name: String):
	if db.has(db_name):
		return db[db_name]
	
	return false	
	
	
