extends TextureRect

export(NodePath) var CarPath
export(NodePath) var MetricsListPath
export(NodePath) var NeedlePath
export(NodePath) var SpeedPath
export(NodePath) var SpeedTypePath

export(int) var MINIMUM_ROTATION
export(int) var MAX_ROTATION
export(bool) var start_with_zero
export(int) var count

var metricListRef
var needleRef
var totalAngle
var speedLabRef
var speedTypeLabRef

func _ready():
	totalAngle = MAX_ROTATION - MINIMUM_ROTATION
	metricListRef = get_node(str(MetricsListPath))
	needleRef = get_node(str(NeedlePath))
	speedLabRef = get_node(str(SpeedPath))
	speedTypeLabRef = get_node(str(SpeedTypePath))
	generateMetricsAndNums()
	setNeedle(0)

func generateMetricsAndNums():
	var mr = 1
	if(start_with_zero):
		mr=0
	for i in range(mr,count):
		var actualMetr = preload("res://Assets/HUD/MetreAndNum.tscn").instance()
		get_node(str(MetricsListPath)).add_child(actualMetr)
		var amountNormalized = float(i) / float(count)
		var actualAngle = MINIMUM_ROTATION + amountNormalized * totalAngle
		actualMetr.set_rotation_degrees(actualAngle)
		actualMetr.setLabel(str(i))
		actualMetr.setLabelGLobalRotation(0)
		
func setNeedle(rpm : float):
	var amountNormalized = rpm / float(count)
	var actualAngle = MINIMUM_ROTATION + amountNormalized * totalAngle
	needleRef.set_rotation_degrees(actualAngle)
	
func setSpeedLabel(speed : int):
	speedLabRef.set_text(str(speed))
	
func setToMiles():
	speedTypeLabRef.set_text("MpH")
func setToMetrics():
	speedTypeLabRef.set_text("Km/H")
	
