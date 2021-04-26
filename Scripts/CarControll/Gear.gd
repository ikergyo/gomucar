extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export(int) var gear_num
export(float) var gear_ratio
var active : bool
export(bool) var reverse
var gear_ratio_for_force : float

# Called when the node enters the scene tree for the first time.
func _ready():
	if(reverse):
		gear_ratio_for_force = (-1) * gear_ratio
	else:
		gear_ratio_for_force = gear_ratio

func get_ger_ratio_for_force():
	return gear_ratio_for_force
	
func get_gear_ratio_for_rpm():
	return gear_ratio
