extends Node
class_name Stats

#Para el futuro por si queremos que ocurra algo cuando se acabe la vida
signal health_depleted()

#Variables a personalizar por personaje
#Básicas
export var character : String #Personaje en uso
export var health : int #Vida actual
export var maxHealth : int setget set_maxHealth #Vida máxima
export var speed : float #Velocidad movimiento
#El nombre y rate de los ataques que voy a tener, que variara segun el character que tenga
export var attackML : String #Ataque Mouse Left
export var attackMR : String #Ataque Mouse Right
export var attackBQ : String #Ataque Button Q
export var mlRate : float #Rate ataque Mouse Left
export var mrRate : float #Rate ataque Mouse Right
export var bqRate : float #Rate ataque Button Q
#Específicas
export var movSpeed : float #Velocidad movilidad
export var movRange : float #Rango movilidad
export var movDuration : float #Duracion movilidad
var myEffects : Array #Todos los posibles efectos que tengo a la vez
onready var baseSpeed = speed

#Siempre la vida tendra un minimo de 0
func set_maxHealth(value):
	maxHealth = max(0, value)
func set_health(value):
	maxHealth = max(0, value)

#FUNCIONES RECIBIR EFECTOS
#Funcion de recibir daño
#Si health llega a 0 emite señal, para que hagamos lo que queramos
func takeDamage(hit):
	health -= hit
	health = max(0, health)
#	print(character, " got hit: ", str(hit), " -> HP: ", str(health), "/", str(maxHealth))
	if health == 0:
		emit_signal("health_depleted")
	return health
#Funcion de recibir heal
func takeHeal(hit):
	health += hit
	health = min(health, maxHealth)
#	print(character, " got healed: ", str(hit), " -> HP: ", str(health), "/", str(maxHealth))
	return health
#Funcion de recibir Poison
func takePoison(hit):
	health -= hit
	if health == 0:
		emit_signal("health_depleted")
#Funcion de recibir stun, velocidad a 0 de momento
func takeStun(slowReduction):
	speed = speed * slowReduction
	return speed
#Funcion de recibir Slow, velocidad a 0.5 de momento
func takeSlow(slowReduction):
	speed = baseSpeed * slowReduction
	return speed
#Funcion de recibir Trap, velocidad a 0 de momento
func takeTrap(slowReduction):
	speed = speed * slowReduction
	return speed
#Funcion de recibir Mute
func takeMute(hit):
	pass
#Funcion de recibir Fear
func takeFear(hit):
	pass
	
#FUNCIONES RECUPERAR ESTADOS TRAS EFECTOS
#Funcion recuperar velocidad tras stuns, slows y demas
func recoverSpeed():
	return baseSpeed
func recoverPoison():
	return health
