extends Node

export(NodePath) var mainMultiplayerPanelPath
export(NodePath) var joinPanelPath
export(NodePath) var hostPanelPath
export(NodePath) var lobbyPanelPath

#JoinData
export(NodePath) var ipAddressPath

#HostData
export(NodePath) var serverNamePath
export(NodePath) var maxPlayersPath

#LobbyDatas
export(NodePath) var lobbyPlayerList
export(PackedScene) var lobbyPlayerTemplate

var activePanel

func _ready():
	init()
	activePanel = mainMultiplayerPanelPath

func init():
	NetworkController.connect("new_connection_initialization_completed", self, "new_connection_completed")
	NetworkController.connect("joining_is_success", self, "sucessfully_joined")
	NetworkController.connect("connection_refused", self, "connection_failed")
	NetworkController.connect("player_disconnected_event", self, "a_player_disconnected")

func terminate():
	NetworkController.disconnect("new_connection_initialization_completed", self, "new_connection_completed")
	NetworkController.disconnect("joining_is_success", self, "sucessfully_joined")
	NetworkController.disconnect("connection_refused", self, "connection_failed")
	NetworkController.disconnect("player_disconnected_event", self, "a_player_disconnected")

func new_connection_completed():
	for id in NetworkController.Player_Infos:
		createNewLobbyPlayer(id)
	refreshLobbyPlayerList()

func a_player_disconnected():
	pass	

func panelChange(panelName):
	get_node(str(activePanel)).hide()
	get_node(str(panelName)).show()
	activePanel = panelName

func sucessfully_joined():
	panelChange(lobbyPanelPath)
	
func sucessfully_created_server():
	panelChange(lobbyPanelPath)
	
func createNewLobbyPlayer(player_id):
	#If there is a lobbyplayer instance for that player, then return
	if(NetworkController.lobbyPlayerInstanceIsExist(player_id)):
		return
	var newLobbyPlayer = lobbyPlayerTemplate.instance()
	newLobbyPlayer.setID(player_id)
	newLobbyPlayer.setName(NetworkController.Player_Infos[player_id].Player_Name)
	newLobbyPlayer.setReady(NetworkController.Player_Infos[player_id].Ready)
	newLobbyPlayer.name = str(player_id) #This is the NodaPathname which is equal the id. If we don't determine this, it will be random, and the master and puppet functions won't work
	if(player_id != NetworkController.Server_Id):
		newLobbyPlayer.set_network_master(player_id)
	NetworkController.setPlayerLobbyInstane(newLobbyPlayer, player_id)
	get_node(str(lobbyPlayerList)).add_child(newLobbyPlayer)

func connection_failed():
	pass
	#Todo a popup will appear
	
#This will sort the list
func refreshLobbyPlayerList():
	var child_list = get_node(str(lobbyPlayerList)).get_children()
	for j in range(0, child_list.size()):
		for i in range(0, child_list.size()-1):
			var actualNodeId = get_node(str(lobbyPlayerList)).get_child(i).P_Id
			var nextNodeId = get_node(str(lobbyPlayerList)).get_child(i+1).P_Id
			if(NetworkController.Player_Infos[actualNodeId].Connection_Order > NetworkController.Player_Infos[nextNodeId].Connection_Order):
				get_node(str(lobbyPlayerList)).move_child(get_node(str(lobbyPlayerList)).get_child(i+1),i)

func _on_JoinButton_pressed():
	var ip = get_node(str(ipAddressPath)).get_text()
	if (str(ip).is_valid_ip_address()):
		NetworkController.join_server(ip)

func _on_HostButton_pressed():
	var serverName = get_node(str(serverNamePath)).get_text()
	var maxPlayers = get_node(str(maxPlayersPath)).get_text()
	if(str(serverName).empty()):
		return
	if(str(maxPlayers).empty()):
		return	
	NetworkController.create_host(int(maxPlayers), serverName)
	sucessfully_created_server()

func _on_to_Join_panel_pressed():
	panelChange(joinPanelPath)

func _on__to_Host_panel_pressed():
	panelChange(hostPanelPath)
