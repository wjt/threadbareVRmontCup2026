extends Node

func show_blackout():
	var rect = get_tree().current_scene.find_child("FadeRect", true, false)
	if rect:
		rect.visible = true
		print("Blackout triggered!")
	else:
		print("Could not find FadeRect!")
