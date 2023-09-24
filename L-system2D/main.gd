extends Node2D

var iterations = 3
var rules = {
	"A":"AB", 
	"B":"A"
}
var starting = {
	"state": "A",
	"pos": Vector2(100,100)
}

var state = starting.state
var length = 100.0
var width = 10.0
var angle = 3

func _draw():
	print(state)
	for i in iterations:
		var holder = ""
		for node in state:
			holder += rules.get(node)
		state = holder
	
	for node in state:
		draw_line(starting.pos, starting.pos+Vector2.UP*length, Color.GOLD, width)
			
	print(state)
