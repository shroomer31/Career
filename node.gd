extends Node

var player2_ai_nodes = {}
var email_system

func _ready():
	email_system = get_parent()

func create_ai_for_character(character_data: Dictionary) -> Node:
	var Player2AINPC = load("res://addons/player2/Player2AINPC.gd")
	if not Player2AINPC:
		print("Player2 AI plugin not found!")
		return null
	
	var ai_node = Player2AINPC.new()
	if not ai_node:
		print("Failed to create AI node!")
		return null
	
	ai_node.set("character_name", character_data["name"])
	ai_node.set("character_description", character_data["system_prompt"])
	var system_message = "You are " + character_data["name"] + ". " + character_data["system_prompt"] + "\n\nYou are writing an email to an insurance company about: " + character_data["first_prompt"] + "\n\nWrite your response in email format, maintaining your unique personality and communication style. Be natural and authentic to your character."
	ai_node.set("character_system_message", system_message)
	print("Created AI node for ", character_data["name"], " with system message: ", system_message)
	
	if ai_node.has_signal("chat_received"):
		ai_node.chat_received.connect(Callable(self, "_on_ai_response").bind(character_data["name"]))
	elif ai_node.has_signal("chat_response"):
		ai_node.chat_response.connect(Callable(self, "_on_ai_response").bind(character_data["name"]))
	
	add_child(ai_node)
	player2_ai_nodes[character_data["name"]] = ai_node
	
	return ai_node

func send_message_to_ai(character_name: String, message: String):
	if player2_ai_nodes.has(character_name):
		var ai_node = player2_ai_nodes[character_name]
		if ai_node:
			ai_node.chat(message)

func handle_ai_response(character_name: String, response: String):
	if email_system:
		email_system.receive_ai_response(character_name, response)

func remove_ai_for_character(character_name: String):
	if player2_ai_nodes.has(character_name):
		var ai_node = player2_ai_nodes[character_name]
		player2_ai_nodes.erase(character_name)
		if ai_node:
			ai_node.queue_free() 

func _on_ai_response(character_name: String, response: String):
	handle_ai_response(character_name, response)
