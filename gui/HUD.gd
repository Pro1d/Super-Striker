extends MarginContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_Ship_health_changed(health, max_health):
	var health_text := $VBoxContainer/HBoxContainer/CenterContainer/Label as Label
	health_text.text = "Health: " + str(health) + "/" + str(max_health)
