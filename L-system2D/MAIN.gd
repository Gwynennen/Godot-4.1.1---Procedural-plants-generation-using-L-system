extends Node2D

var parts = []
var polyPoints
var drawble = "FH"
var skips = "fh"
var constants = "-+[]|#!@{}.<>&()"
var swapFlag = 1
var rules
var colors = {
	"F": Color.SADDLE_BROWN,
	"H": Color.BLACK,
	"dot": Color.DARK_GREEN
}
var starting
var current
var checkpoint = {
	"pos": [],
	"dir": []
}
var steps = 5
var TW

func _ready():
	randomize()
	rules = load_preset("P2")
	current = starting.duplicate(true)
	$Camera2D.position = starting.pos
	TW = create_tween()
	TW.finished.connect(func(): 
		var doneLabel = Label.new()
		doneLabel.text = "DONE"
		add_child(doneLabel)
		)
	calculate_draw()

func load_preset(presetName: String):
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
						starting.pos = Vector2(DisplayServer.window_get_size().x/starting.posX_ratio, DisplayServer.window_get_size().y/starting.posY_ratio)
						starting.dir = Vector2(starting.dirX, starting.dirY)
					_:
						preset_data[key] = presets.get_value(p, key)
						
			
			return preset_data

func calculate_draw():
# calculating state
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

# drawing
	for part in current.state:
		if part in drawble:
			var tmpLength = current.length if part == "F" else current.length/2
			var newPos = current.pos + current.dir*tmpLength
			var line = Line2D.new()
			line.add_point(current.pos)
			line.add_point(current.pos)
			line.set_width(current.width)
			line.set_default_color(colors[part])
			parts.append(line)
			add_child(line)
			TW.tween_method((func(newPos, line): line.set_point_position(line.get_point_count()-1, newPos)).bind(line), current.pos, newPos, 0.01).set_trans(Tween.TRANS_LINEAR)
			current.pos = newPos
		elif part in skips:
			current.pos = current.pos + current.dir*current.length
		elif part in constants:
			match part:
				"-": current.dir = current.dir.rotated(-current.angle * swapFlag)
				"+": current.dir = current.dir.rotated(current.angle * swapFlag)
				"[": 
					checkpoint.pos.append(current.pos)
					checkpoint.dir.append(current.dir)
				"]": 
					current.pos = checkpoint.pos.pop_back()
					current.dir = checkpoint.dir.pop_back()
				"|":
					current.width -= deg_to_rad(180)
				"#":
					current.width += current.widthDelta
				"!":
					current.width -= current.widthDelta
				"<":
					current.length += current.lengthDelta
				">":
					current.length -= current.lengthDelta
				"(":
					current.angle += current.angleDelta
				")":
					current.angle -= current.angleDelta
				"@":
					var line = Line2D.new()
					var newPos = current.pos + current.dir*current.width
					line.add_point(current.pos)
					line.add_point(current.pos)
					line.set_width(current.width)
					line.set_default_color(colors.dot)
					parts.append(line)
					add_child(line)
					TW.tween_method((func(newPos, line): line.set_point_position(line.get_point_count()-1, newPos)).bind(line), current.pos, newPos, 0.01).set_trans(Tween.TRANS_LINEAR)
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
				"&":
					swapFlag = 1 if swapFlag == -1 else 1



