extends Node

signal chat_received(response: String)
signal chat_response(response: String)

var character_name: String = ""
var character_description: String = ""
var character_system_message: String = ""
var config: Player2APIConfig

func _ready():
	# Initialize Player2 configuration
	config = Player2APIConfig.new()
	# Use default endpoints from Player2APIConfig


func chat(message: String):
	var request = Player2Schema.ChatCompletionRequest.new()
	request.messages = []
	
	var system_msg = Player2Schema.Message.new()
	system_msg.role = "system"
	system_msg.content = character_system_message
	request.messages.append(system_msg)
	
	var context_msg = Player2Schema.Message.new()
	context_msg.role = "user"
	context_msg.content = "You are responding to an email from an insurance company customer service representative. The customer wrote: '" + message + "'\n\nPlease respond as " + character_name + " in email format, maintaining your unique personality and communication style."
	request.messages.append(context_msg)
	
	Player2API.chat(config, request, 
		Callable(self, "_on_chat_complete"), 
		Callable(self, "_on_chat_error")
	)

func _on_chat_complete(response):
	if response and response.has("choices") and response["choices"].size() > 0:
		var ai_response = response["choices"][0]["message"]["content"]
		chat_received.emit(ai_response)
		chat_response.emit(ai_response)
	else:
		print("No valid response from AI")
		print("Response: ", response)

func _on_chat_error(error_code):
	print("Chat failed with error code: ", error_code)
