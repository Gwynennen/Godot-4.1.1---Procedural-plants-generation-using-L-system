extends Node2D

var parts = []
var drawble = "FH"
var skips = "fh"
var actions = "-+[]|#!{}.<>&()L"
var rules
var starting
var current


func _ready():
	randomize()
	var ground = Polygon2D.new()
	var limitBot = DisplayServer.window_get_size().y/8*7
	ground.set_polygon(PackedVector2Array([
		Vector2(0, limitBot), 
		Vector2(DisplayServer.window_get_size().x, limitBot),
		Vector2(DisplayServer.window_get_size().x,DisplayServer.window_get_size().y),
		Vector2(0,DisplayServer.window_get_size().y)
	]))
	ground.set_color(Color.SADDLE_BROWN.darkened(0.5))
	add_child(ground)
	
	start("Tree1", Vector2(DisplayServer.window_get_size().x/4, limitBot), 5, Color.SADDLE_BROWN)
	start("Tree1", Vector2(DisplayServer.window_get_size().x/4*2, limitBot), 5, Color.SADDLE_BROWN)
	start("Tree1", Vector2(DisplayServer.window_get_size().x/4*3, limitBot), 5, Color.SADDLE_BROWN)
	
func start(preset_name: String, startingPos: Vector2, steps, color):
	rules = load_settings(preset_name)
	current = starting.duplicate(true)
	current.pos = startingPos
	current.color = color
	calculate_state(steps)
	draw_parts(set_tween())

func load_settings(presetName: String):
	var preset_data = {}
	var presets = ConfigFile.new()
	var err = presets.load("presets.cfg")

	if err != OK:
		return

	for p in presets.get_sections():
		if p == presetName:
			for key in presets.get_section_keys(p):
				match key:
					"values":
						starting = presets.get_value(p, key)
						starting.angle = deg_to_rad(starting.angle)
						starting.angleDelta = deg_to_rad(starting.angleDelta)
						starting.dir = Vector2(starting.dirX, starting.dirY)
					_:
						preset_data[key] = presets.get_value(p, key)
						
			return preset_data
	push_error("No such preset in config")

func calculate_state(steps):
	for step in steps:
		var tmp = ""
		for part in current.state:
			if part in rules:
				if randi_range(0, 99) in range(0, rules[part].pbty):
					tmp += rules[part].main
				else:
					tmp += rules[part].second
			else:
				tmp += part
		current.state = tmp

func draw_parts(TW):
	var polyPoints
	var swapFlag = 1
	var checkpoint = {
		"pos": [],
		"dir": []
	}
	for part in current.state:
		if part in drawble:
			var newPos = current.pos + current.dir * (current.length if part == "F" else current.length/2)
			var line = Line2D.new()
			line.add_point(current.pos)
			line.add_point(current.pos)
			line.set_width(current.width)
			line.set_default_color(current.color)
			current.color = current.color.lightened(0.001)
			parts.append(line)
			add_child(line)
			TW.tween_method((func(newPos, line): line.set_point_position(line.get_point_count()-1, newPos)).bind(line), current.pos, newPos, 0.01).set_trans(Tween.TRANS_LINEAR)
			current.pos = newPos
		elif part in skips:
			current.pos = current.pos + current.dir*current.length
		elif part in actions:
			match part:
#				handle stack
				"[": 
					checkpoint.pos.append(current.pos)
					checkpoint.dir.append(current.dir)
				"]": 
					current.pos = checkpoint.pos.pop_back()
					current.dir = checkpoint.dir.pop_back()
				
#				handle angles
				"-": current.dir = current.dir.rotated(-current.angle * swapFlag).normalized()
				"+": current.dir = current.dir.rotated(current.angle * swapFlag).normalized()
				"(":
					current.angle += current.angleDelta
				")":
					current.angle -= current.angleDelta
				"|":
					current.angle -= deg_to_rad(180)
				
#				width
				"#":
					current.width += current.widthDelta
				"!":
					current.width -= current.widthDelta
					
#				length	
				"<":
					current.length += current.lengthDelta
				">":
					current.length -= current.lengthDelta

#				handle leaves
				"L":
					var leaf = Polygon2D.new()
					var newPos = PackedVector2Array([current.pos, current.pos+current.dir.rotated(150)*current.length*2, current.pos+current.dir.rotated(300)*current.length*2])
					leaf.set_polygon(PackedVector2Array([current.pos, current.pos+current.dir*current.width,current.pos+current.dir*current.width]))
					leaf.set_color(Color.GREEN)
					parts.append(leaf)
					add_child(leaf)
					TW.tween_method((func(newPos, leaf): leaf.set_polygon(newPos)).bind(leaf), leaf.get_polygon(), newPos, 0.01).set_trans(Tween.TRANS_LINEAR)
					
#				handle polygon
				"{":
					polyPoints = PackedVector2Array()
					polyPoints.append(current.pos)			
				".":
					polyPoints.append(current.pos)
				"}":
					polyPoints.append(current.pos)
					var poly = Polygon2D.new()
					poly.color = Color.YELLOW
					poly.set_polygon(polyPoints)
					polyPoints = PackedVector2Array()

# 				reverse +- action
				"&":
					swapFlag = 1 if swapFlag == -1 else 1

func set_tween():
	var TW = create_tween()
	TW.finished.connect(func(): 
		var doneLabel = Label.new()
		doneLabel.text = "DONE"
		add_child(doneLabel)
	)
	
	return TW

