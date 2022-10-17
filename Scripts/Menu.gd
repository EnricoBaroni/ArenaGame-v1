extends Node2D
onready var characterSelection = $CharacterSelect

func _on_Play_pressed():
	get_tree().change_scene("res://Levels/ArenaGame.tscn")

func _on_Exit_pressed():
	get_tree().quit()
