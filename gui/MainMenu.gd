extends MarginContainer


func _on_start_pressed():
	get_tree().change_scene("res://world.tscn")

func _on_exit_pressed():
	get_tree().quit()
