extends Node

export(String) var engine_name
export(float) var differential_ratio
export(int) var max_gear_num = 5
export(Array, NodePath) var gears
export(Dictionary) var torque_rpm_curve
export(float) var max_rpm
export(float) var min_torque
export(float) var transmissionEfficiency = 0.7

export(NodePath) var wheelFrontLeft
export(NodePath) var wheelFrontRight
export(NodePath) var wheelBackLeft
export(NodePath) var wheelBackRight

#0 = Default, vagyis ures.
var actual_gear = 0
var actual_gear_ref
var wheelRadius
var engine_rpm = 0

func _ready():
	wheelFrontLeft = get_node(str(wheelFrontLeft))
	wheelFrontRight = get_node(str(wheelFrontRight))
	wheelBackLeft = get_node(str(wheelBackLeft))
	wheelBackRight = get_node(str(wheelBackRight))
	wheelRadius = wheelBackRight.get_radius()
	
func _physics_process(delta):
	calculateRPM()

func get_real_engine_force():
	if (engine_rpm > max_rpm || actual_gear == 0):
		return 0
	return calculateEngineForce(get_actual_torque(), actual_gear_ref.get_ger_ratio_for_force())
	
#Egyenes egyenlete x: rpm, y: torque
func get_torque_from_curve(rpmLower : float, torqueLower : float, rpmActual : float, rpmHigher : float, torqueHigher : float):
	return (((torqueHigher - torqueLower)*(rpmActual-rpmLower))/(rpmHigher-rpmLower))+torqueLower

func get_actual_torque():
	var i = 0
	var previous_rpm = 0
	for rpm_in_curve in torque_rpm_curve:
		if i == 0 && engine_rpm < rpm_in_curve:
			return min_torque
		elif engine_rpm > previous_rpm && engine_rpm < rpm_in_curve:
			return get_torque_from_curve(previous_rpm, torque_rpm_curve[previous_rpm], engine_rpm, rpm_in_curve, torque_rpm_curve[rpm_in_curve])
		i += 1
		previous_rpm = rpm_in_curve
	return 0

func calculateRPM():
	if actual_gear == 0:
		engine_rpm = abs(wheelBackRight.get_rpm())
	else:
		engine_rpm = abs(wheelBackRight.get_rpm() * actual_gear_ref.get_gear_ratio_for_rpm() * differential_ratio)
	
func calculateEngineForce(motorTorque : float, gearRatio : float):
	return (motorTorque * gearRatio * differential_ratio * transmissionEfficiency)/wheelRadius

func search_and_set_gear(gear_number : int):
	for act_gear in gears:
		var act_gear_ref = get_node(str(act_gear))
		if act_gear_ref.gear_num == gear_number:
			actual_gear_ref = act_gear_ref
			return
	return
		
func gear_up():
	
	if actual_gear == max_gear_num:
		return
	actual_gear += 1
	search_and_set_gear(actual_gear)
		
func gear_down():
	if actual_gear == -1:
		return

	actual_gear -= 1
	search_and_set_gear(actual_gear)
