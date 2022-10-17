extends "res://Characters/Player.gd"
class_name PlayerGunner

#Elige los ataques que se realizan segun character
func _physics_process(delta):
	chooseAttacks(muteBullet, bigBullet, dodge)
