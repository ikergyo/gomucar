extends Node

enum difficulties { Easy, Normal, Hard }

#This is the menu where we can go back if the game ended
var defaultMenuScene = "res://Scenes/Menu/MainMenu.tscn"
var current_scene = null


# Called when the node enters the scene tree for the first time.
func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)

	
#It will handle the scene changes, because we can handle it only one place
func changeScene(newScene):
	call_deferred("_deferred_goto_scene", newScene)

func _deferred_goto_scene(newScene):
	# It is now safe to remove the current scene
	current_scene.free()

	# Load the new scene.
	var s = ResourceLoader.load(newScene)

	# Instance the new scene.
	current_scene = s.instance()

	# Add it to the active scene, as child of root.
	get_tree().get_root().add_child(current_scene)

	# Optionally, to make it compatible with the SceneTree.change_scene() API.
	get_tree().set_current_scene(current_scene)
