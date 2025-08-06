extends Node

signal ceo_call_ui_opened()
signal ceo_call_ui_closed()
signal player_promoted(new_rank: int)

# CEO dialogue data based on reputation levels
var ceo_dialogues = {
	"greeting": {
		"low": [  # 0-30 reputation
			"*sigh* Listen, I don't have much time for this...",
			"Right, you're... remind me who you are again?",
			"I suppose we should talk. Keep it brief."
		],
		"medium": [  # 31-70 reputation  
			"Ah, there you are. I've been hearing some things about your work.",
			"Good to see you. How are things going down there?",
			"I have a few minutes. What's your progress report?"
		],
		"high": [  # 71+ reputation
			"Excellent! Just the person I wanted to speak with.",
			"My star performer! How are you doing today?",
			"Perfect timing. I've been looking forward to our chat."
		]
	},
	"personality": {
		"low": [
			"You know, results speak louder than excuses.",
			"I need to see more dedication from you.",
			"The company expects excellence, not mediocrity."
		],
		"medium": [
			"I appreciate your steady work. Keep pushing forward.",
			"You're on the right track. Show me you can handle more responsibility.",
			"Good progress. I like seeing consistent improvement."
		],
		"high": [
			"Your work has been outstanding lately!",
			"I'm genuinely impressed with your performance.",
			"You've exceeded my expectations consistently."
		]
	},
	"promotion": {
		"low": [
			"A promotion? Let's focus on meeting basic expectations first.",
			"You'll need to prove yourself much more before we discuss advancement.",
			"I'm afraid I don't see promotion material just yet."
		],
		"medium": [
			"You're getting closer to promotion territory. Keep it up.",
			"I'm considering some changes. Show me you're ready for more.",
			"A promotion might be possible if you maintain this level."
		],
		"high": [
			"You know what? You've earned a promotion. Congratulations!",
			"I'm promoting you effective immediately. Well deserved!",
			"Your dedication has paid off. Welcome to your new position!"
		]
	},
	"boredom": [
		"Well, I have other calls to make...",
		"I think that's enough for now.",
		"This conversation has run its course.",
		"I need to get back to more pressing matters.",
		"Time is money, and this call is over."
	]
}

var current_dialogue_index = 0
var ceo_boredom_level = 0.0
var ceo_boredom_threshold = 100.0
var ceo_interest_level = 50.0
var dialogue_history = []
var promotion_offered = false

var ui_elements = {}

func _ready():
	# Connect to Global signals
	if Global:
		Global.connect("ceo_call_joined", Callable(self, "_on_ceo_call_joined"))
		Global.connect("ceo_call_window_opened", Callable(self, "_on_ceo_call_window_opened"))
		Global.connect("ceo_call_window_closed", Callable(self, "_on_ceo_call_window_closed"))

# Input is handled in screen.gd to avoid conflicts

func _on_ceo_call_window_opened():
	show_call_notification()

func _on_ceo_call_window_closed():
	hide_call_notification()

func _on_ceo_call_joined():
	start_ceo_call_interface()

func show_call_notification():
	print("CEO is calling! Press E to join (", Global.get_ceo_call_window_time_left(), " seconds left)")
	# TODO: Show UI notification

func hide_call_notification():
	print("Call window closed.")
	# TODO: Hide UI notification

func start_ceo_call_interface():
	print("=== CEO CALL STARTED ===")
	reset_call_state()
	emit_signal("ceo_call_ui_opened")
	show_ceo_dialogue()

func reset_call_state():
	current_dialogue_index = 0
	ceo_boredom_level = 0.0
	ceo_interest_level = 50.0
	dialogue_history.clear()
	promotion_offered = false

func show_ceo_dialogue():
	var reputation_tier = get_reputation_tier()
	var greeting = get_random_dialogue("greeting", reputation_tier)
	
	print("\n--- CEO ---")
	print(greeting)
	
	dialogue_history.append({"speaker": "ceo", "text": greeting, "tier": reputation_tier})
	
	# Show player response options
	show_player_options()

func show_player_options():
	print("\nChoose your response:")
	print("1. Ask about work performance")
	print("2. Request promotion")
	print("3. Discuss company goals") 
	print("4. End the call")
	print("Enter your choice (1-4):")
	
	# For now, simulate a choice - in actual game this would be UI buttons
	# This is a placeholder for the actual UI implementation
	handle_player_choice(randi() % 4 + 1)

func handle_player_choice(choice: int):
	var player_response = ""
	var ceo_response = ""
	
	match choice:
		1:
			player_response = "How am I performing in my current role?"
			ceo_response = handle_performance_question()
		2:
			player_response = "I'd like to discuss a potential promotion."
			ceo_response = handle_promotion_request()
		3:
			player_response = "What are your priorities for the company?"
			ceo_response = handle_company_goals()
		4:
			player_response = "Thank you for your time. I should get back to work."
			end_ceo_call()
			return
	
	print("\n--- You ---")
	print(player_response)
	
	dialogue_history.append({"speaker": "player", "text": player_response})
	
	# Process CEO's response
	process_ceo_response(ceo_response)

func handle_performance_question() -> String:
	var reputation_tier = get_reputation_tier()
	var response = get_random_dialogue("personality", reputation_tier)
	
	# Moderate interest increase for asking about work
	increase_ceo_interest(10.0)
	
	return response

func handle_promotion_request() -> String:
	var reputation_tier = get_reputation_tier()
	var response = get_random_dialogue("promotion", reputation_tier)
	
	# High reputation = promotion, medium = interest, low = boredom
	if reputation_tier == "high" and not promotion_offered:
		promotion_offered = true
		promote_player()
		increase_ceo_interest(30.0)
	elif reputation_tier == "medium":
		increase_ceo_interest(5.0)
	else:
		increase_ceo_boredom(20.0)
	
	return response

func handle_company_goals() -> String:
	var responses = [
		"We're focused on growth and customer satisfaction.",
		"Innovation and efficiency are our top priorities.",
		"Building the best team in the industry is key."
	]
	
	# Slight interest increase for showing company interest
	increase_ceo_interest(5.0)
	
	return responses[randi() % responses.size()]

func process_ceo_response(response: String):
	print("\n--- CEO ---")
	print(response)
	
	dialogue_history.append({"speaker": "ceo", "text": response})
	
	# Simulate CEO getting bored over time
	increase_ceo_boredom(randi() % 15 + 5)
	
	# Check if CEO wants to end call
	if should_ceo_end_call():
		end_call_due_to_boredom()
	else:
		# Continue conversation
		await get_tree().create_timer(2.0).timeout
		show_player_options()

func promote_player():
	if Global.increase_rank():
		var new_rank = Global.rank
		print("\n🎉 PROMOTION! 🎉")
		print("Congratulations! You've been promoted to ", Global.get_rank_title())
		emit_signal("player_promoted", new_rank)
		
		# Add bonus reputation and money for promotion
		Global.add_reputation(15.0)
		Global.add_money(500.0)

func increase_ceo_interest(amount: float):
	ceo_interest_level = min(100.0, ceo_interest_level + amount)
	# Interest reduces boredom
	ceo_boredom_level = max(0.0, ceo_boredom_level - amount * 0.5)

func increase_ceo_boredom(amount: float):
	ceo_boredom_level = min(100.0, ceo_boredom_level + amount)
	# Boredom reduces interest
	ceo_interest_level = max(0.0, ceo_interest_level - amount * 0.3)

func should_ceo_end_call() -> bool:
	# End call if boredom is too high or random chance based on boredom
	return ceo_boredom_level >= ceo_boredom_threshold or \
		   (ceo_boredom_level > 60.0 and randf() < (ceo_boredom_level / 200.0))

func end_call_due_to_boredom():
	var boredom_response = ceo_dialogues["boredom"][randi() % ceo_dialogues["boredom"].size()]
	print("\n--- CEO ---")
	print(boredom_response)
	
	await get_tree().create_timer(1.0).timeout
	end_ceo_call()

func end_ceo_call():
	print("\n=== CEO CALL ENDED ===")
	print("Call summary:")
	print("- Reputation tier: ", get_reputation_tier())
	print("- CEO interest level: ", ceo_interest_level)
	print("- CEO boredom level: ", ceo_boredom_level)
	if promotion_offered:
		print("- PROMOTION RECEIVED! 🎉")
	
	emit_signal("ceo_call_ui_closed")
	Global.end_ceo_call()

func get_reputation_tier() -> String:
	var rep = Global.reputation
	if rep <= 30:
		return "low"
	elif rep <= 70:
		return "medium"
	else:
		return "high"

func get_random_dialogue(category: String, tier: String) -> String:
	var dialogues = ceo_dialogues[category][tier]
	return dialogues[randi() % dialogues.size()]