extends AudioStreamPlayer

var songs: Array[AudioStream] = []
var current_song_index: int = 0

func _ready():
	load_songs_from_folder("res://music/")
	
	if songs.size() > 0:
		stream = songs[current_song_index]
		play()
		finished.connect(_on_song_finished)

func load_songs_from_folder(path: String):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				if file_name.ends_with(".ogg") or file_name.ends_with(".mp3") or file_name.ends_with(".wav"):
					var stream = load(path + file_name)
					if stream is AudioStream:
						songs.append(stream)
			file_name = dir.get_next()
		dir.list_dir_end()

func _on_song_finished():
	current_song_index = (current_song_index + 1) % songs.size()
	stream = songs[current_song_index]
	play()
