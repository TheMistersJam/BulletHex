extends Control

func _ready():
	pass


func _on_Button_pressed():
	$fd.popup()


func _on_fd_file_selected(path):
	goto_world(path)

func goto_world(level_to_load):
	call_deferred("_deferred_load_world", level_to_load)

func _deferred_load_world(level_to_load):
	
	var s = ResourceLoader.load("res://Code/main.tscn")
	
	var world_i = s.instance()
	world_i.load_level(level_to_load)
	
	get_tree().get_root().add_child(world_i)
	get_tree().set_current_scene(world_i)
	
	queue_free()
