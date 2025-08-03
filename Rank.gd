extends Node

var ranks = [
	"Intern",
	"Junior Staff",
	"Associate",
	"Manager",
	"Director",
	"Vice President",
	"President",
	"CEO"
]

var rank_index := 0

func get_rank() -> String:
	return ranks[rank_index]

func promote():
	if rank_index < ranks.size() - 1:
		rank_index += 1
	else:
		print("Already at top rank!")

func reset_rank():
	rank_index = 0
