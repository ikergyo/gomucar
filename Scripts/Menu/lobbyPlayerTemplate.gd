extends HBoxContainer

export(NodePath) var idPath
export(NodePath) var playerNamePath
export(NodePath) var readyButtonPath

var isReady
var P_Id

func _ready():
	init()
	if(!is_network_master()):
		disableReadyButton()
	pass # Replace with function body.

func init():
	if(isReady):
		if(is_network_master()):
			get_node(str(readyButtonPath)).set_text("Unready")
		else:
			get_node(str(readyButtonPath)).set_text("Ready")
	else:
		if(is_network_master()):
			get_node(str(readyButtonPath)).set_text("Ready")
		else:
			get_node(str(readyButtonPath)).set_text("Not ready")

func setID(newId):
	P_Id = newId
	get_node(str(idPath)).set_text(str(newId))
	
func setName(newName):
	get_node(str(playerNamePath)).set_text(newName)

func setReady(readyBool):
	isReady = readyBool

master func changeReadyState():
	if(isReady):
		get_node(str(readyButtonPath)).set_text("Ready")
		rpc("changeToNotReady")
	else:
		get_node(str(readyButtonPath)).set_text("Unready")
		rpc("changeToReady")
	isReady = !isReady

puppet func changeToNotReady():
	get_node(str(readyButtonPath)).set_text("Not ready")

puppet func changeToReady():
	get_node(str(readyButtonPath)).set_text("Ready")
	
puppet func changeToDisable():
	disableReadyButton()
	
func disableReadyButton():
	get_node(str(readyButtonPath)).set_disabled(true)

func _on_readyButton_pressed():
	NetworkController.setReadyState()
	rpc("changeReadyState")
	pass # Replace with function body.
