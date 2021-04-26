extends Control

#MainPanels
export(NodePath) var mainStartMenuPath
export(NodePath) var singleMapSelectionPanelPath
export(NodePath) var multiplayerPanelPath

export(NodePath) var singlePlayButtonPath
export(NodePath) var multiplayerPlayButtonPath
export(NodePath) var settingsButtonPath

#SingleMenuTHings

export(NodePath) var singleStartGameButtonPath

export(NodePath) var mapListGridPath
export(PackedScene) var mapThumbnailTemplatePath

var activeMenuPanel = ""
var mapThumbInstances = []

#We can interate in this array and load a selectable map from the template
#var selectableMaps = [
#	{ name = "MainTestMap", mapThumbnailPath = "res://Assets/Pictures/MapsThumbnails/TestMap.PNG", labelTexturePath = "", realMapScene = "res://Scenes/Maps/Main.tscn"}
#]
#func genereta_mapThumbs_from_code():
#	for m in selectableMaps:
#		var tempMapThumb = mapThumbnailTemplatePath.instance()
#		if(m.labelTexturePath != null):
#			tempMapThumb.set_labelTexture(load(m.labelTexturePath))
#		if(m.mapThumbnailPath != null):
#			tempMapThumb.set_mapThumbTexture(load(m.mapThumbnailPath))
#		tempMapThumb.set_gameSceneReference(m.realMapScene)
#		mapThumbInstances.append(tempMapThumb)
#		get_node(str(mapListGridPath)).add_child(tempMapThumb)

export(Array, PackedScene) var map_scenes
func generate_mapThumbs_from_inherited_scenes():
	for m in map_scenes:
		var tempMapThumb = m.instance()
		mapThumbInstances.append(tempMapThumb)
		get_node(str(mapListGridPath)).add_child(tempMapThumb)

func _ready():
	activeMenuPanel = mainStartMenuPath
	generate_mapThumbs_from_inherited_scenes()
	pass # Replace with function body.

#If a map selected return the index
func checkMapIsSelected():
	for m in mapThumbInstances:
		if(m.is_Selected()):
			return m
	return false

func panelChange(panelName):
	get_node(str(activeMenuPanel)).hide()
	get_node(str(panelName)).show()
	activeMenuPanel = panelName

func _on_SingleStartGameButton_pressed():
	var selectedMap = checkMapIsSelected()
	if (selectedMap):
		get_tree().set_pause(true)
		DefaultGameController.changeScene(selectedMap.get_selectedMap())		
		get_tree().set_pause(false)
	pass # Replace with function body.

func _on_SinglePlayerButton_pressed():
	panelChange(singleMapSelectionPanelPath)
	pass # Replace with function body.

func _on_MultiplayerButton_pressed():
	panelChange(multiplayerPanelPath)
	pass # Replace with function body.
	
func _on_MultiplayerPanel_hide():
	#If the panel hide, you need to disconnect from the server or if you are the server, it will delete it.
	#NetworkController.to_disconnect()
	pass # Replace with function body.
