extends Node2D
class_name Bullet

#Inicializacion stats
var typeWeapon
var speed
var damage
var duration
var maxRange
var effectType

onready var statsWeapon = $StatsWeapon #Obtenemos stats del arma
onready var hitbox = $Hitbox
onready var direction = Vector2.ZERO #En principio no tiene direccion hasta que se asigne
#(Cuidado que segun tiene mas velocidad llega mas distancia)
onready var distance = statsWeapon.maxRange #Para controlar la distancia que llega junto a delta 
var timer = 0 #Timer para evitar que por lag dure mas o menos
var effectHit = load("res://Effects/HitEffect.tscn")

func _ready():
	initializeStats()
	$AnimationPlayer.play("Play")

func _physics_process(delta):
	global_position += direction * delta
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
func setAttackPlayer():
	hitbox.set_collision_mask_bit(2, true)
	hitbox.set_collision_mask_bit(4, false)
func setAttackChar():
	hitbox.set_collision_mask_bit(4, true)
	hitbox.set_collision_mask_bit(2, false)
func setReflected():
	direction = direction * -1
#Configura que efectos apareceran en el otro area al golpearla, dependiendo del tipo de bala
func _on_Hitbox_area_entered(area): #Cuando entro en otro area
	if area.monitoring: #Si es golpeable, añadimos efecto
		var hitEffect = effectHit.instance() #Instanciamos
		get_parent().add_child(hitEffect) #La añadimos a la escena
		hitEffect.position = self.position #Hacemos que aparezca encima de lo que golpeamos

