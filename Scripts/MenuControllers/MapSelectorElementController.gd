extends Control

export(NodePath) var labelTexturePath
export(NodePath) var mapThumbnailPath
export(NodePath) var selectedtexturePath
export(PackedScene) var gameSceneReferencePath

var selected = false


func _ready():
	print(gameSceneReferencePath)
	pass # Replace with function body.

func is_Selected():
	return selected

func select_element():
	get_node(str(selectedtexturePath)).show()
	selected = true
	
func deselect_element():
	get_node(str(selectedtexturePath)).hide()
	selected = false

func _on_Element_mouse_entered():
	pass # Replace with function body.

func _on_Element_mouse_exited():
	pass # Replace with function body.

func _on_Element_pressed():
	if(selected):
		deselect_element()
	else:
		select_element()
	pass # Replace with function body.

func set_labelTexture(loadedTexture):
	get_node(str(labelTexturePath)).set_texture(loadedTexture)

func set_mapThumbTexture(loadedTexture):
	get_node(str(mapThumbnailPath)).set_texture(loadedTexture)

func set_gameSceneReference(scene):
	gameSceneReferencePath = scene
func get_selectedMap():
	return gameSceneReferencePath.get_path()
