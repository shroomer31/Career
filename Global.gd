extends Node

signal stats_changed(stat_name: String, old_value: float, new_value: float)
signal rank_up(new_rank: int)
signal rank_down(new_rank: int)
signal ceo_call_started()
signal ceo_call_window_opened()
signal ceo_call_window_closed()
signal ceo_call_joined()
signal ceo_call_ended()

var money: float = 1000.0
var rank: int = 1
var reputation: float = 50.0
var stored_text: String = ""

# CEO Call System
var ceo_call_timer: float = 0.0
var ceo_call_interval: float = 600.0  # 10 minutes
var ceo_call_window_duration: float = 30.0  # 30 seconds
var ceo_call_window_active: bool = false
var ceo_call_in_progress: bool = false
var ceo_call_window_timer: float = 0.0

var rank_thresholds = {
	1: {"min_reputation": 0, "salary_per_second": 1, "title": "Trainee"},
	2: {"min_reputation": 25, "salary_per_second": 3, "title": "Junior Agent"},
	3: {"min_reputation": 50, "salary_per_second": 5, "title": "Senior Agent"},
	4: {"min_reputation": 75, "salary_per_second": 8, "title": "Lead Agent"},
	5: {"min_reputation": 90, "salary_per_second": 12, "title": "Manager"}
}

var max_money: float = 100000.0
var max_reputation: float = 100.0
var min_reputation: float = 0.0

func _ready():
	update_rank()

func _process(delta):
	var salary = get_rank_salary_per_second()
	add_money(salary * delta)
	
	# Handle CEO call system
	handle_ceo_call_system(delta)

func add_money(amount: float) -> bool:
	if amount <= 0:
		return false
	
	var old_money = money
	money = min(money + amount, max_money)
	
	emit_signal("stats_changed", "money", old_money, money)
	return true

func remove_money(amount: float) -> bool:
	if amount <= 0:
		return false
	
	var old_money = money
	money = max(money - amount, 0.0)
	
	emit_signal("stats_changed", "money", old_money, money)
	return true

func set_money(new_amount: float) -> bool:
	if new_amount < 0 or new_amount > max_money:
		return false
	
	var old_money = money
	money = new_amount
	
	emit_signal("stats_changed", "money", old_money, money)
	return true

func increase_rank() -> bool:
	if rank >= 5:
		return false
	
	var old_rank = rank
	rank += 1
	
	emit_signal("rank_up", rank)
	emit_signal("stats_changed", "rank", old_rank, rank)
	return true

func decrease_rank() -> bool:
	if rank <= 1:
		return false
	
	var old_rank = rank
	rank -= 1
	
	emit_signal("rank_down", rank)
	emit_signal("stats_changed", "rank", old_rank, rank)
	return true

func set_rank(new_rank: int) -> bool:
	if new_rank < 1 or new_rank > 5:
		return false
	
	var old_rank = rank
	rank = new_rank
	
	if new_rank > old_rank:
		emit_signal("rank_up", rank)
	else:
		emit_signal("rank_down", rank)
	
	emit_signal("stats_changed", "rank", old_rank, rank)
	return true

func add_reputation(amount: float) -> bool:
	if amount <= 0:
		return false
	
	var old_reputation = reputation
	reputation = min(reputation + amount, max_reputation)
	
	emit_signal("stats_changed", "reputation", old_reputation, reputation)
	check_rank_change()
	return true

func remove_reputation(amount: float) -> bool:
	if amount <= 0:
		return false
	
	var old_reputation = reputation
	reputation = max(reputation - amount, min_reputation)
	
	emit_signal("stats_changed", "reputation", old_reputation, reputation)
	check_rank_change()
	return true

func set_reputation(new_reputation: float) -> bool:
	if new_reputation < min_reputation or new_reputation > max_reputation:
		return false
	
	var old_reputation = reputation
	reputation = new_reputation
	
	emit_signal("stats_changed", "reputation", old_reputation, reputation)
	check_rank_change()
	return true

func check_rank_change():
	var current_rank_data = rank_thresholds[rank]
	var next_rank = rank + 1
	
	if next_rank <= 5 and reputation >= rank_thresholds[next_rank]["min_reputation"]:
		increase_rank()
	elif reputation < current_rank_data["min_reputation"]:
		decrease_rank()

func update_rank():
	for r in range(5, 0, -1):
		if reputation >= rank_thresholds[r]["min_reputation"]:
			if rank != r:
				set_rank(r)
			break

func get_rank_title() -> String:
	return rank_thresholds[rank]["title"]

func get_rank_salary_per_second() -> float:
	return rank_thresholds[rank]["salary_per_second"]

func get_stats_dict() -> Dictionary:
	return {
		"money": money,
		"rank": rank,
		"reputation": reputation,
		"rank_title": get_rank_title(),
		"salary_per_second": get_rank_salary_per_second()
	}

func reset_stats():
	money = 1000.0
	rank = 1
	reputation = 50.0
	update_rank()

func process_email_response(quality: float, customer_satisfaction: float):
	var reputation_gain = (quality + customer_satisfaction) * 5.0
	var money_gain = (quality + customer_satisfaction) * 50.0
	
	add_reputation(reputation_gain)
	add_money(money_gain)
	
	return {
		"reputation_gained": reputation_gain,
		"money_gained": money_gain,
		"quality": quality,
		"satisfaction": customer_satisfaction
	}

func process_email_failure(severity: float):
	var reputation_loss = severity * 10.0
	var money_loss = severity * 100.0
	
	remove_reputation(reputation_loss)
	remove_money(money_loss)
	
	return {
		"reputation_lost": reputation_loss,
		"money_lost": money_loss,
		"severity": severity
	}

# CEO Call System Methods
func handle_ceo_call_system(delta: float):
	if ceo_call_in_progress:
		return
	
	if ceo_call_window_active:
		ceo_call_window_timer += delta
		if ceo_call_window_timer >= ceo_call_window_duration:
			close_ceo_call_window()
	else:
		ceo_call_timer += delta
		if ceo_call_timer >= ceo_call_interval:
			trigger_ceo_call()

func trigger_ceo_call():
	print("CEO is calling! Press E within 30 seconds to join the call.")
	ceo_call_window_active = true
	ceo_call_window_timer = 0.0
	emit_signal("ceo_call_window_opened")

func close_ceo_call_window():
	print("CEO call window expired.")
	ceo_call_window_active = false
	ceo_call_timer = 0.0
	emit_signal("ceo_call_window_closed")

func join_ceo_call() -> bool:
	if not ceo_call_window_active or ceo_call_in_progress:
		return false
	
	print("Joining CEO call...")
	ceo_call_window_active = false
	ceo_call_in_progress = true
	emit_signal("ceo_call_joined")
	return true

func end_ceo_call():
	print("CEO call ended.")
	ceo_call_in_progress = false
	ceo_call_timer = 0.0
	emit_signal("ceo_call_ended")

func is_ceo_call_window_active() -> bool:
	return ceo_call_window_active

func is_ceo_call_in_progress() -> bool:
	return ceo_call_in_progress

func get_ceo_call_window_time_left() -> float:
	if not ceo_call_window_active:
		return 0.0
	return max(0.0, ceo_call_window_duration - ceo_call_window_timer)

func get_time_until_next_ceo_call() -> float:
	if ceo_call_window_active or ceo_call_in_progress:
		return 0.0
	return max(0.0, ceo_call_interval - ceo_call_timer) 
