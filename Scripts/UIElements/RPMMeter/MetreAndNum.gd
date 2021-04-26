extends NinePatchRect

export(NodePath) var infoLabel
export(NodePath) var parentLabel

var labelRef
var parentLabelRef

func _ready():
	labelRef = get_node(str(infoLabel))
	parentLabelRef = get_node(str(parentLabel))
	
func setLabel(newText : String):
	labelRef.set_text(newText)
	
func setLabelGLobalRotation(rotationDegree : float):
	parentLabelRef.set_global_rotation_degrees(rotationDegree)

