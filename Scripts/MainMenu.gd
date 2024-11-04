extends Control

#preload submenus
var connections = preload("res://Scenes/Menus/Connection_menu.tscn")
var options = preload("res://Scenes/Menus/Option_menu.tscn")

#start button pressed. Open connection menu
func _on_start_button_pressed():
	var connections_node = connections.instantiate()
	get_tree().current_scene.add_child(connections_node)

#Options button pressed. Open options menu
func _on_options_button_pressed():
	var options_node = options.instantiate()
	get_tree().current_scene.add_child(options_node)

#Quit button pressed. Quit
func _on_quit_button_pressed():
	get_tree().quit()
