extends Node2D
class_name PoisonBullet

#Inicializacion stats
var typeWeapon
var speed
var damage
var duration
var maxRange
var effectType

onready var statsWeapon = $StatsWeapon #Obtenemos stats del arma
onready var direction = Vector2.ZERO #En principio no tiene direccion hasta que se asigne
#(Cuidado que segun tiene mas velocidad llega mas distancia)
onready var distance = statsWeapon.maxRange #Para controlar la distancia que llega junto a delta 

func _ready():
	initializeStats()
	$AnimationPlayer.play("Play")

func _physics_process(delta):
	global_position += direction * delta
	rotation += 0.1 #Hacemos que vaya girando segun avanza
	distance -= 1
	if distance == 0:
		queue_free()

#Inicializamos nuestras stats
func initializeStats():
	typeWeapon = statsWeapon.typeWeapon
	speed = statsWeapon.speed
	damage = statsWeapon.damage
	duration = statsWeapon.duration
	maxRange = statsWeapon.maxRange
	effectType = statsWeapon.effectType

func setDirection(directionVectorSet):
	direction = directionVectorSet * speed
#Obtener informacion desde otros sitios
func getName():
	return typeWeapon
func getDamage(): #Para poder saber cuanto daño hace al entrar en otras areas
	return damage
func getDuration(): #Para poder saber cuanto dura al entrar en otras areas
	return duration
func getEffectType():
	return effectType

func _on_Hitbox_area_entered(area):
	queue_free()
