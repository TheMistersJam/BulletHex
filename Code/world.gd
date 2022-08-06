extends Spatial

func _ready():
	pass

func load_level(path):
	#var importer = PackedSceneGLTF.new()
	#var importer = EditorSceneImporterGLTF.new()
	#var level = importer.import_gltf(path)
	var gstate = load("res://addons/godot_gltf/GLTFState.gdns").new()
	var importer = load("res://addons/godot_gltf/PackedSceneGLTF.gdns").new()

	var level = importer.import_gltf_scene(path, 0, 1000, gstate)
	parse_level(level)
	call_deferred("add_child", level)

func parse_level(l):
	var e_rx = RegEx.new()
	var p_rx = RegEx.new()
	var c_rx = RegEx.new()
	var e_ent = load("res://Code/Enemy.tscn")
	var p_ent = load("res://Code/Player.tscn")
	e_rx.compile("-hint.?(\\d\\d\\d)?$")
	p_rx.compile("-phint.?(\\d\\d\\d)?$")
	c_rx.compile("-chint.?(\\d\\d\\d)?$")
	for _i in l.get_children():
		print_debug(_i)
		if _i.name.ends_with("-colonly"):
			print_debug("Generating collision mesh for ", _i.name)
			_i.create_trimesh_collision()
			_i.visible=false
		elif e_rx.search(_i.name):
			print_debug("Found enemy in ", _i.name)
			var ne = e_ent.instance()
			ne.translation = _i.translation
			add_child(ne)
		elif p_rx.search(_i.name):
			print_debug("Found player in ", _i.name)
			var np = p_ent.instance()
			np.translation = _i.translation
			add_child(np)
		elif c_rx.search(_i.name):
			print_debug("Found camera hint in ", _i.name)
			print_debug("Camera loc: ", _i.translation, "rot:", _i.rotation_degrees)
			var nc = Camera.new()
			nc.translation = _i.translation
			nc.rotation = _i.rotation + Vector3(PI/2, 0, 0)
			nc.fov = 50
			nc.name = "Camera"
			add_child(nc)
