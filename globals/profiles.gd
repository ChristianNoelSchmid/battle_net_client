extends Node
var profiles: Array = []

func get_profile(id):
	if profiles.size() == 0:
		profiles = _load_profiles()
	
	return profiles[id - 1]

func _load_profiles():
	var file = FileAccess.open("res://assets/profiles.json", FileAccess.READ)
	var content = file.get_as_text()
	var json = JSON.parse_string(content)

	var new_profiles = []
	for item in json:
		var profile = load("res://models/profile_model.gd").new()
		profile.parse_variant(item)
		new_profiles.push_back(profile)

	return new_profiles
