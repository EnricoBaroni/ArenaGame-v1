extends "res://Characters/Player.gd"
class_name PlayerMage

#Elige los ataques que se realizan segun character
func _physics_process(delta):
	chooseAttacks(poisonBullet, fearBullet, teletransport) 
