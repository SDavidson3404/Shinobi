extends Node

func _ready():
	# Call fade_in deferred to ensure SceneTree exists
	call_deferred("_do_fade_in")

func _do_fade_in():
	FadeManager.fade_in()
