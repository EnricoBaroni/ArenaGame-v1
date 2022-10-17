extends "res://Characters/Player.gd"
class_name PlayerWarrior

#Elige los ataques que se realizan segun character
func _physics_process(delta):
	chooseAttacks(slowBullet, trapBullet, reflect) 
