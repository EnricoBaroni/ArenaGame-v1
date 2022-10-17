extends "res://Characters/Player.gd"
class_name PlayerHealer

#Elige los ataques que se realizan segun character
func _physics_process(delta):
	chooseAttacks(healBullet, stunBullet, invisible) 
