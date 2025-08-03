extends Node

@export var output_folder := "res://characters/"

func _ready():
	var dir = DirAccess.open(output_folder)
	if dir == null:
		push_error("Folder does not exist: " + output_folder)
		return
	
	generate_characters(50)
	print("Generated 50 characters in %s" % output_folder)

func generate_characters(count: int) -> void:
	for i in count:
		var char_data = create_character(i)
		var filename = "%s/character_%02d.json" % [output_folder, i + 1]
		save_json_file(filename, char_data)

func create_character(index: int) -> Dictionary:
	var names = [
		"Aiden Durand", "Bella Sparks", "Charlie Whiskers", "Daisy Thunder", "Eli Rocket",
		"Fiona Flicker", "Gus Glitter", "Hazel Hoot", "Ivy Zoom", "Jax Jumble",
		"Kiki Quirk", "Luna Loop", "Milo Munch", "Nina Noodle", "Ollie Orbit",
		"Piper Pounce", "Quinn Quest", "Rory Ripple", "Sasha Swirl", "Toby Twister",
		"Uma Unicorn", "Vince Vortex", "Willa Wink", "Xander Xplode", "Yara Yawn",
		"Zane Zip", "Amber Astro", "Brock Boulder", "Cora Comet", "Dex Dash",
		"Elle Ember", "Finn Flash", "Gia Glimmer", "Hank Hurdle", "Izzy Ignite",
		"Jade Jinx", "Kara Kaleido", "Leo Leap", "Maya Mirage", "Nico Nimbus",
		"Opal Orbit", "Pax Prism", "Quincy Quake", "Rhea Rocket", "Skylar Spark",
		"Ty Titan", "Una Uproar", "Vera Vibe", "Wade Whirl", "Zara Zoom"
	]

	var first_prompts = [
		"Ask if skate ramp damage counts under your policy.",
		"Question about alien pet insurance coverage.",
		"Inquire if slime spills are included.",
		"Wonder if robot dance battles void the contract.",
		"Ask if backyard volcano eruptions are insured.",
		"Query about enchanted tree damage liabilities.",
		"Check if magic wand breakage is covered.",
		"Ask about insurance for invisible ink spills.",
		"Wonder if potion explosions count as accidents.",
		"Check if flying carpets are covered under travel insurance."
	]

	var system_prompts = {
		"Aiden Durand": "You are Aiden Durand. You're a rebellious teenager who was forced to get insurance. You are sarcastic, brief, and unimpressed.",
		"Bella Sparks": "You are Bella Sparks. You're an energetic young inventor who loves sparks and gadgets. You speak quickly and excitedly.",
		"Charlie Whiskers": "You are Charlie Whiskers. You're a curious cat kid who loves naps and mischief. Your tone is playful and sly.",
		"Daisy Thunder": "You are Daisy Thunder. You're a storm chaser kid who's loud and bold, always excited to share a story.",
		"Eli Rocket": "You are Eli Rocket. You're a space enthusiast who dreams of stars. You speak with wonder and optimism."
	}

	var name = names[index % names.size()]
	var first_prompt = first_prompts[index % first_prompts.size()]
	var system_prompt = system_prompts.get(name, "You are %s. You have a unique personality that fits a fun, kid-friendly story." % name)
	var first_email = generate_first_email(name)

	return {
		"first_prompt": first_prompt,
		"name": name,
		"system_prompt": system_prompt,
		"first_email": first_email
	}

func generate_first_email(name: String) -> Dictionary:
	var titles = [
		"Help! My Skate Ramp Went Boom!",
		"My Alien Pet Made a Mess!",
		"Slime Disaster in the Living Room",
		"Robot Dance Battle Gone Wrong",
		"Backyard Volcano Alert!",
		"Enchanted Tree Accident Report",
		"Magic Wand Mishap",
		"Invisible Ink Explosion",
		"Potion Pop Surprise",
		"Flying Carpet Trouble"
	]

	var paragraphs = [
		"Dear Insurance Team, I was skating super fast when I totally crashed my ramp! Do you cover this kind of epic disaster? Please let me know before I have to build another one!",
		"Hi! My pet Zorg from outer space knocked over the furniture again. Is there insurance for alien pet shenanigans? Thanks a bunch!",
		"Oh no! The slime experiment got out of control and now my living room looks like a gooey swamp. Does my policy cover slime spills?",
		"Hey, I was winning the robot dance battle when one of the bots fell and smashed the floor. Does that count as damage?",
		"Warning! The backyard volcano I made erupted way too big and made a mess. Will my insurance help clean it up?",
		"Hello! An enchanted tree dropped magic nuts on my roof. Can you cover enchanted tree accidents?",
		"Oops! My magic wand exploded while practicing spells. Is wand damage included in my coverage?",
		"Hi team! I spilled invisible ink all over my homework and my desk. Does that count as damage?",
		"Dear folks, a potion popped and splashed everywhere. Is potion explosion damage covered?",
		"Hello! My flying carpet had a bumpy landing and tore a hole in the garage door. Can you help fix that?"
	]

	var idx = abs(name.hash()) % titles.size()
	return {
		"title": titles[idx],
		"body": paragraphs[idx]
	}

func save_json_file(path: String, data: Dictionary) -> void:
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Failed to open file: " + path)
		return
	
	var json = JSON.new()
	var json_text = json.stringify(data, "\t")  # pretty print with tabs
	file.store_string(json_text)
	file.close()
