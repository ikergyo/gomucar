extends Node

#Elements
export(NodePath) var labelPath
export(NodePath) var lineEditPath

#Settings
export(bool) var is_edit_only_num

func _ready():
	pass # Replace with function body.

func _on_Edit_text_changed(new_text):
	if(!is_edit_only_num):
		return
		
	var onlyNums = GlobalFunctions.getOnlyNumsFromTeText(new_text)
	get_node(str(lineEditPath)).set_text(onlyNums)
