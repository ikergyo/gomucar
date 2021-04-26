extends VehicleBody

export (NodePath) var wheel 
export (NodePath) var engine 
export (NodePath) var rpmmeter 
var engine_ref
var wheel_ref
var rpmMeterRef

############################################################
# behaviour values
#In Km/h
export var MAX_VELOCITY = 80
export var MAX_ENGINE_FORCE = 200.0
export var MAX_BRAKE_FORCE = 40.0
export var MAX_STEER_ANGLE = 0.5

export var steer_speed = 5.0

var steer_target = 0.0
var steer_angle = 0.0

############################################################
# Input

export var joy_steering = JOY_ANALOG_LX
export var steering_mult = -1.0
export var joy_throttle = JOY_ANALOG_R2
export var throttle_mult = 1.0
export var joy_brake = JOY_ANALOG_L2
export var brake_mult = 1.0

#Local vars


func _ready():
	rpmMeterRef = get_node(str(rpmmeter))
	engine_ref = get_node(str(engine))
	#rpmMeterRef.setSpeedLabel(0)

func _physics_process(delta):
	var steer_val = steering_mult * Input.get_joy_axis(0, joy_steering)
	var throttle_val = throttle_mult * Input.get_joy_axis(0, joy_throttle)
	var brake_val = brake_mult * Input.get_joy_axis(0, joy_brake)
	
	# overrules for keyboard
	if Input.is_action_pressed("ui_up"):
		throttle_val = -0.5
	if Input.is_action_pressed("ui_down"):
		throttle_val = 0.5
	if Input.is_action_pressed("brake"):
		brake_val = 1.0
	if Input.is_action_just_pressed("shift_up"):
		engine_ref.gear_up()
	if Input.is_action_just_pressed("shift_down"):
		engine_ref.gear_down()
	if Input.is_action_pressed("ui_left"):
		steer_val = 1.0
	elif Input.is_action_pressed("ui_right"):
		steer_val = -1.0
	
	var current_velocity_in_km = linear_velocity.length() * 3.6
	var current_velocity_in_mph = linear_velocity.length() * 2.2369
	
	rpmMeterRef.setNeedle(engine_ref.engine_rpm/1000)
	rpmMeterRef.setSpeedLabel(int(current_velocity_in_km))
	
	#print (current_velocity_in_km)
	
	engine_force = throttle_val * engine_ref.get_real_engine_force()
	brake = brake_val * MAX_BRAKE_FORCE
	
	steer_target = steer_val * MAX_STEER_ANGLE
	if (steer_target < steer_angle):
		steer_angle -= steer_speed * delta
		if (steer_target > steer_angle):
			steer_angle = steer_target
	elif (steer_target > steer_angle):
		steer_angle += steer_speed * delta
		if (steer_target < steer_angle):
			steer_angle = steer_target
	
	steering = steer_angle



	
