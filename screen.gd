extends Node2D

signal email_created(email_data: Dictionary)
signal email_responded(email_data: Dictionary, response_quality: float)

var characters_folder = "res://characters/"
var email_templates = []
var page_templates = []
var current_time = 0.0
var email_timer = 60.0
var pending_ai_responses = {}

@onready var page_template = $PageTemplate
@onready var email_template = $EmailTemplate
@onready var player2_integration = $Player2Integration

func _ready():
	if page_template:
		page_template.visible = false
	if email_template:
		email_template.visible = false
	load_characters()

func _process(delta):
	current_time += delta
	if current_time >= email_timer:
		current_time = 0.0
		create_new_email()

func load_characters():
	var dir = DirAccess.open(characters_folder)
	if dir:
		for file in dir.get_files():
			if file.ends_with(".json"):
				var file_path = characters_folder + file
				var file_content = FileAccess.get_file_as_string(file_path)
				var character_data = JSON.parse_string(file_content)
				if character_data:
					create_email_from_character(character_data)

func create_email_from_character(character_data: Dictionary):
	if not email_template:
		return
	var new_email_template = email_template.duplicate()
	new_email_template.visible = true
	add_child(new_email_template)
	
	var info_control = new_email_template.get_node("Control")
	if info_control:
		var name_label = info_control.get_node("Name")
		var time_label = info_control.get_node("Time")
		
		if name_label:
			name_label.text = character_data["name"]
		if time_label:
			var current_hour = int(Time.get_time_dict_from_system()["hour"])
			var current_minute = int(Time.get_time_dict_from_system()["minute"])
			time_label.text = str(current_hour) + ":" + str(current_minute).pad_zeros(2)
	
	var open_button = new_email_template.get_node("Open")
	var delete_button = new_email_template.get_node("Delete")
	
	if open_button:
		open_button.pressed.connect(func(): open_email_page(character_data, new_email_template))
	if delete_button:
		delete_button.pressed.connect(func(): delete_email(new_email_template))
	
	email_templates.append(new_email_template)
	
	var page = create_page_template(character_data, new_email_template)
	if page:
		page_templates.append(page)
	
	if player2_integration:
		player2_integration.create_ai_for_character(character_data)

func create_page_template(character_data: Dictionary, email_template_node) -> Node:
	if not page_template:
		return null
	var new_page = page_template.duplicate()
	new_page.visible = false
	add_child(new_page)
	
	var info_control = new_page.get_node("Info")
	if not info_control:
		return null
	var scroll_container = info_control.get_node("ScrollContainer")
	if not scroll_container:
		return null
	var vbox = scroll_container.get_node("VBoxContainer")
	if not vbox:
		return null
	
	var title_label = vbox.get_node("Title")
	var info_label = vbox.get_node("Info")
	var name_label = vbox.get_node("Name")
	
	if title_label:
		title_label.text = character_data["first_prompt"]
	if info_label:
		info_label.text = character_data["system_prompt"]
	if name_label:
		name_label.text = character_data["name"]
	
	var respond_control = new_page.get_node("Respond")
	if respond_control:
		var send_button = respond_control.get_node("Send")
		var text_edit = respond_control.get_node("TextEdit")
		
		if send_button and text_edit:
			send_button.pressed.connect(func(): send_response(character_data, text_edit.text, new_page, email_template_node))
	
	return new_page

func open_email_page(character_data: Dictionary, email_template_node):
	email_template_node.modulate = Color.GRAY
	
	for page in page_templates:
		var page_info = page.get_node("Info")
		var page_vbox = page_info.get_node("ScrollContainer").get_node("VBoxContainer")
		var page_name = page_vbox.get_node("Name")
		
		if page_name.text == character_data["name"]:
			page.visible = true
			break

func delete_email(email_template_node):
	var page_to_delete = null
	var character_name = ""
	
	var info_control = email_template_node.get_node("Control")
	if info_control:
		var name_label = info_control.get_node("Name")
		if name_label:
			character_name = name_label.text
	
	for page in page_templates:
		var page_info = page.get_node("Info")
		if page_info:
			var page_vbox = page_info.get_node("ScrollContainer").get_node("VBoxContainer")
			if page_vbox:
				var page_name = page_vbox.get_node("Name")
				if page_name and page_name.text == character_name:
					page_to_delete = page
					break
	
	if page_to_delete:
		page_templates.erase(page_to_delete)
		page_to_delete.queue_free()
	
	email_templates.erase(email_template_node)
	email_template_node.queue_free()
	
	if player2_integration and character_name != "":
		player2_integration.remove_ai_for_character(character_name)

func send_response(character_data: Dictionary, player_response: String, page_node, email_template_node):
	var respond_control = page_node.get_node("Respond")
	if not respond_control:
		return
	var vbox = respond_control.get_node("VBoxContainer")
	if not vbox:
		return
	
	var player_info_label = Label.new()
	player_info_label.text = "Player"
	vbox.add_child(player_info_label)
	
	var player_response_label = Label.new()
	player_response_label.text = player_response
	vbox.add_child(player_response_label)
	
	pending_ai_responses[character_data["name"]] = {
		"page_node": page_node,
		"email_template_node": email_template_node,
		"character_data": character_data
	}
	
	if player2_integration:
		player2_integration.send_message_to_ai(character_data["name"], player_response)

func receive_ai_response(character_name: String, ai_response: String):
	if pending_ai_responses.has(character_name):
		var pending_data = pending_ai_responses[character_name]
		var page_node = pending_data["page_node"]
		var email_template_node = pending_data["email_template_node"]
		var character_data = pending_data["character_data"]
		
		var respond_control = page_node.get_node("Respond")
		if respond_control:
			var vbox = respond_control.get_node("VBoxContainer")
			if vbox:
				var ai_info_label = Label.new()
				ai_info_label.text = character_data["name"]
				vbox.add_child(ai_info_label)
				
				var ai_response_label = Label.new()
				ai_response_label.text = ai_response
				vbox.add_child(ai_response_label)
		
		email_template_node.modulate = Color.WHITE
		
		var response_quality = evaluate_response_quality(ai_response, character_data)
		process_email_outcome(response_quality, character_data)
		
		emit_signal("email_responded", character_data, response_quality)
		
		pending_ai_responses.erase(character_name)

func evaluate_response_quality(ai_response: String, character_data: Dictionary) -> float:
	var quality = 0.5
	
	if "thank" in ai_response.to_lower():
		quality += 0.2
	if "appreciate" in ai_response.to_lower():
		quality += 0.2
	if "help" in ai_response.to_lower():
		quality += 0.1
	
	return min(quality, 1.0)

func process_email_outcome(response_quality: float, character_data: Dictionary):
	var outcome = ""
	
	if response_quality >= 0.8:
		outcome = "upgrade"
		Global.add_reputation(10.0)
		Global.add_money(100.0)
	elif response_quality >= 0.6:
		outcome = "keep"
		Global.add_reputation(5.0)
		Global.add_money(50.0)
	elif response_quality >= 0.4:
		outcome = "neutral"
		Global.add_reputation(1.0)
		Global.add_money(10.0)
	else:
		outcome = "complaint"
		Global.remove_reputation(5.0)
		Global.remove_money(25.0)

func create_new_email():
	var character_files = []
	var dir = DirAccess.open(characters_folder)
	if dir:
		for file in dir.get_files():
			if file.ends_with(".json"):
				character_files.append(file)
	
	if character_files.size() > 0:
		var random_file = character_files[randi() % character_files.size()]
		var file_path = characters_folder + random_file
		var file_content = FileAccess.get_file_as_string(file_path)
		var character_data = JSON.parse_string(file_content)
		if character_data:
			create_email_from_character(character_data) 
