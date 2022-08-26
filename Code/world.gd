extends Spatial

var timescale

const SLOW_PERIOD = 0.3
const SLOW_AMP = 0.8

var time_set
var isSlowing
var powerup_inst = preload("res://Code/Powerup.tscn")
var enem_count = 0

func _ready():
	time_set = SLOW_PERIOD
	isSlowing = false
	timescale = 1.0

#ramps up from 0 to a, then back to 0 in the time of b	
func time_tween1(x, a, b): #x is pos, a is amplitude, b is period
	return ((a*0.5)*sin(((2*x/b)-0.5)*PI))+(a*0.5)

#starts at a, then goes to 0 in the time of b	
func time_tween2(x, a, b): #x is pos, a is amplitude, b is period
	return ((a*0.5)*sin(((x/b)+0.5)*PI))+(a*0.5)
	
func flash_slow():
	time_set = 0
	isSlowing = true
	
	
func _process(delta):
	if isSlowing:
		time_set += delta
		timescale = 1 + time_tween2(time_set, -SLOW_AMP, SLOW_PERIOD)
		if time_set > SLOW_PERIOD:
			time_set = SLOW_PERIOD
			timescale = 1.0
			isSlowing = false

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
			enem_count += 1
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

func remove_enemy():
	enem_count -= 1
	if enem_count <= 0:
		spawn_powerups()

func spawn_powerups():
	print_debug("Spawning powerups...")
	var newp = powerup_inst.instance()
	newp.translate(Vector3(1, 1, 1))
	add_child(newp)
