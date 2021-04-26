extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func loadMap(selectedMap):
	var world = load(selectedMap).instance()

