extends Node
enum GameStages{ Initialized, Lobby, GameIsStarted }
enum playerSceneTypes { Constant, Unique, FullUnique }

const is_Server_a_Player = true
const disable_connections_after_game_started = true
const default_network_port = 42456

var Server_Id = null
var My_id = null
var Player_Infos = {}

#It is necessary separately, because we send data from Player_Infos and we cant send instances, only primitves
var Lobby_Player_Instances = {}
var Server_Datas = {}

#Network's stages and settings
var GameStage
var playerSceneType = playerSceneTypes.Unique

#Assets
var GameScene = null
var PlayerScene = null

#Sign when a new player connected, only on the server and it send the new player's id as well
signal player_connected_event
#Sign when a layer has been disconnected. It will sign on the rest of the joined players.
signal player_disconnected_event
#Sign when player status is changed, exactly when the ready status is changed on the lobby. It sign in every player
signal player_status_is_changed
#Sign every time, when a new player has been added to your Player_Infos. (When you join the server, you will get all of the already joined players, it will be sign as many times players are joined)
signal player_registered 
#Sign only the new connection, when you joined the server, and get all of the necessary datas
signal registration_initialization_completed
#Sign for everyone on the server, when a new player has been joined and initialized
signal new_connection_initialization_completed
#Sign, when server is created, so it will be sign when only the server is done
signal server_is_created
#Sign when you connected to the server successfully
signal joining_is_success
#Sign when you wanted to connect, but there was a problem, and you can't. It will sign only after 30sec.
signal connection_refused
#Sign when the map/gamescene has been loaded successfully into the memory, but the scene isn't changed yet. It sign on every player but of course only when it is loadaed locally. It don't contain information about the other players
signal world_is_loaded
#Sign when the player instances for the gamsecene have been loaded successfully into the memory, but the scene isn't changed yet. It sign on every player but of course only when it is loadaed locally. It don't contain information about the other players
signal player_instances_created
#This sign when every player are ready, but only for the server.
signal every_player_are_ready

func _ready():
	if(playerSceneType == playerSceneTypes.Constant):
		pass
	elif(playerSceneType == playerSceneTypes.Unique):
		PlayerScene = {}
	pass

func init():
	GameStage = GameStages.Initialized
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	
func terminate():
	My_id = null
	Player_Infos.clear()
	GameScene = null
	PlayerScene = null
	Lobby_Player_Instances.clear()
	get_tree().disconnect("network_peer_connected", self, "_player_connected")
	get_tree().disconnect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().disconnect("connected_to_server", self, "_connected_ok")
	get_tree().disconnect("connection_failed", self, "_connected_fail")
	get_tree().disconnect("server_disconnected", self, "_server_disconnected")

func setConnectedPlayers():
	Server_Datas.JoinedPlayers = Player_Infos.size()

func getEmptyUser(player_id):
	var orderNumber = Player_Infos.size() + 1 
	#Details can contain oher datas, for example team data. team id etc
	return { Player_Id = player_id, Player_Name = "Richard Dobmarel", Connection_Order = orderNumber, Ready = false, LoadingDone = false, Details = {}}

func to_disconnect():
	#It will disconnect. If this is the server, the parameter is relvant because it means, it will be closed after that time (it is in usec)
	#In this case, almost immediately
	get_tree().get_network_peer().close_connection(1)
	#Maybe it is not necessary, but not problem to set null, because maybe there will be an offline mode, and it is disable the online things.
	get_tree().set_network_peer(null)
	terminate()
	
remote func setServerId(server_id):
	Server_Id = server_id

func lobbyPlayerInstanceIsExist(player_id):
	if (Lobby_Player_Instances.has(player_id) && Lobby_Player_Instances[player_id] != null):
		return true
	return false
	
func setPlayerLobbyInstane(lobbyPlayerInstance, player_id):
	Lobby_Player_Instances[player_id] = lobbyPlayerInstance
	
func deleteLobbyPlayerInstance(player_id):
	Lobby_Player_Instances[player_id].queue_free() #it is store the instance, we can delete it and it will remove from the tree as well (in the gui)
	Lobby_Player_Instances.erase(player_id)
	
#Gamescene is the map.
func set_Game_Scene(game_scene_resource):
	if(get_tree().is_network_server() && GameStage == GameStages.Lobby):
		rpc("changeGameScene", game_scene_resource)
remotesync func changeGameScene(newGameScene):
	GameScene = newGameScene
	
#It can setuop the player scene which will be used in the gamescene.
func set_Player_Scene(newPlayerScene):
	rpc_id(Server_Id, "server_set_Player_Scene", newPlayerScene, My_id)

remotesync func server_set_Player_Scene(newPlayerScene, sender_id):
	if(get_tree().is_network_server()):
		if(playerSceneType == playerSceneTypes.Constant):
			rpc("change_Player_Scene", newPlayerScene)
		elif(playerSceneType == playerSceneTypes.Unique):
			rpc("change_Player_Scene_Id", sender_id, newPlayerScene)

remotesync func change_Player_Scene(player_scene_resource):
	PlayerScene = 	player_scene_resource
		
remotesync func change_Player_Scene_Id(player_id, player_scene_resource):
	PlayerScene[player_id] = player_scene_resource
		
func _player_connected(id):
	#We restrict that it will be called only on the server, anything and it will send the datas to the connected nodes.
	if(get_tree().is_network_server()):
		server_add_new_connection(id)

func server_add_new_connection(id):
	var new_player_info = getEmptyUser(id)
	rpc("register_player", new_player_info)
	emit_signal("player_connected_event", id)
	#If the player is the server, then not necessary to send the datas to the other player, becuse server is the first player.
	if(id == Server_Id):
		new_connection_completed()
		return
		
	for p in Player_Infos:
		if(p != id):
			rpc_id(id, "register_player", Player_Infos[p])
	if(GameScene != null):
		rpc_id(id, "changeGameScene", GameScene)
		
	rpc_id(id, "reg_initialization_completed")
	rpc_id(id, "set_server_datas", Server_Datas)
	rpc("new_connection_completed")
	
#It will call on the new connection, after every data has been sent to him/her
remote func reg_initialization_completed():
	emit_signal("registration_initialization_completed")
	
#Send a message to all of the connections, the new player has been intitialized
remotesync func new_connection_completed():
	setConnectedPlayers()
	emit_signal("new_connection_initialization_completed")
#It is gonna set up the server datas from the server. It could be great, when you want to check your friend, and they can answer about the server. There is enough place to join or not, server name etc.
remote func set_server_datas(server_data):
	Server_Datas = Server_Datas

func _player_disconnected(id):
	reorder_players(Player_Infos[id].Connection_Order)
	Player_Infos.erase(id)
	deleteLobbyPlayerInstance(id)
	if(playerSceneType == playerSceneTypes.Unique && PlayerScene.has(id)):
		PlayerScene.erase(id)
	emit_signal("player_disconnected_event", id)
#If a player disconnect, then it will decrease the connection_order number on every player which has greater connection order number
#So the order won't change, just the determinateion of the new player's order will be easier. because it will get just the size of the dictionary
func reorder_players(orderNumber):
	for p in Player_Infos:
		if(Player_Infos[p].Connection_Order > orderNumber):
			Player_Infos[p].Connection_Order = Player_Infos[p].Connection_Order - 1

func _connected_ok():
	My_id = get_tree().get_network_unique_id()
	GameStage = GameStages.Lobby
	emit_signal("joining_is_success")
	pass

func _server_disconnected():
	to_disconnect()

#It will call after 30 seconds!!!
func _connected_fail():
	to_disconnect()
	emit_signal("connection_refused")
	pass # Could not even connect to server; abort.

remotesync func register_player(new_player):
	Player_Infos[new_player.Player_Id] = new_player
	emit_signal("player_registered")

remotesync func setPlayerReadyStatus(player_id):
	Player_Infos[player_id].Ready = !Player_Infos[player_id].Ready
	if(get_tree().is_network_server()):
		check_ready()
	emit_signal("player_status_is_changed", player_id)

func check_erveryone_is_ready():
	for p in Player_Infos:
		if (!Player_Infos[p].Ready):
			return false
	return true

func setReadyState():
	rpc("setPlayerReadyStatus", My_id)

func check_ready():
	if(get_tree().is_network_server()):
		if(check_erveryone_is_ready()):
			#Send a signal only for the server if every player are ready in the lobby
			emit_signal("every_player_are_ready")
			
func send_pre_configure_message():
	if(get_tree().is_network_server()):
		rpc("pre_configure_game")

remotesync func pre_configure_game():
	#_process and _physics_process will not be called anymore in nodes
	# _input and _input_event will not be called anymore either
	get_tree().set_pause(true)
	
	# Load world
	var world = load(GameScene).instance()
	emit_signal("world_is_loaded")

	for player_id in Player_Infos:
		var player = null
		if(playerSceneType == playerSceneTypes.Constant):
			player = load(PlayerScene).instance()
		elif (playerSceneType == playerSceneTypes.Unique):
			player = load(PlayerScene[My_id]).instance()
			
		if (!(player_id == My_id && get_tree().is_network_server())):
			player.set_network_master(player_id)
			
	emit_signal("player_instances_created")
	
	#TODO: Find a solution to place these intances in the spawnpoints. Server randomize it and then send to the clients
	
	# Tell server (remember, server is always ID=1) that this peer is done pre-configuring.
	rpc_id(Server_Id, "done_preconfiguring", My_id)

func every_player_is_done():
	for p in Player_Infos:
		if(!Player_Infos[p].LoadingDone):
			return false
	return true

remotesync func done_preconfiguring(who):
	# Here are some checks you can do, for example
	assert(get_tree().is_network_server())
	assert(who in Player_Infos) # Exists
	assert(!Player_Infos[who].LoadingDone) # Was not added yet

	Player_Infos[who].LoadingDone = true
	
	if (every_player_is_done()):
		rpc("post_configure_game")

remotesync func post_configure_game():
	if(get_tree().is_network_server()):
		get_tree().get_network_peer().set_refuse_new_connections(true)
	GameStage = GameStages.GameIsStarted
	get_tree().set_pause(false)
	#Game starts now!

func create_host(max_players: int, server_name: String):
	init()
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(default_network_port, max_players)
	get_tree().set_network_peer(peer)
	My_id = get_tree().get_network_unique_id()
	Server_Id = My_id
	GameStage = GameStages.Lobby
	Server_Datas = { Server_Name = server_name, Max_Player = max_players, Map = null, JoinedPlayers = 1}
	server_add_new_connection(My_id)
	emit_signal("server_is_created")

func join_server(GameIpAddress):
	init()
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(GameIpAddress, default_network_port)
	get_tree().set_network_peer(peer)
	
	
