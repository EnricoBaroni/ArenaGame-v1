extends KinematicBody2D
class_name Player

#INICIALIZACIONES Y VARIABLES
#Stats
var character
var health
var maxHealth
var speed
var movilitySpeed
var movilityRange
var movilityDuration
var myEffect
var attackMR
var attackML
#TEXTO FLOTANTE
var floating_text = preload("res://Scenes/FloatingText.tscn")
#Utilidades
var canShootML = true #Si puede disparar click izquierdo
var canShootMR = true #Si puede disparar click izquierdo
var canShootBQ = true #Si puede disparar click izquierdo
var direction = Vector2() #Direccion en la que se mueve el player
var directionMovility = Vector2() #Direccion en la que es el dodge
var rangLength #Que longitud tuvo el vector char-mouse
var startPoint
var movilitied

enum { #Distintos estados
	IDLE,
	MOVE,
	ATTACK,
	DODGE,
	TELETRANSPORT,
	INVISIBLE,
	REFLECT
}
var state = IDLE #Para los posibles estados del jugador, por defecto IDLE
#Onready basicos
onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var stats: Stats = $Stats
onready var pivot = $AttackPosition #Donde aparecera el arma, de donde surgen los disparos o skills
onready var attackRateML = $AttackRateML
onready var attackRateMR = $AttackRateMR
onready var attackRateBQ = $AttackRateBQ
onready var hurtboxPlayer = $Hurtbox
onready var sprite = $Sprite
onready var blinkAnimationPlayer = $BlinkAnimationPlayer
onready var lifebar = $Lifebar
onready var lifebarText = $Lifebar/LifebarText
#Animaciones
var effectImmune = load("res://Effects/ImmuneEffect.tscn")
var immuneEffect
var effectImmune2 = load("res://Effects/Immune2Effect.tscn")
var immuneEffect2
var effectReflect = load("res://Effects/ReflectEffect.tscn")
var reflectEffect
var effectInvisibility = load("res://Effects/InvisibleEffect.tscn")
var invisibilityEffect
#Instancias tipos weapons
onready var bullet = preload("res://Weapons/Bullet.tscn")
onready var bigBullet = preload("res://Weapons/BigBullet.tscn")
onready var stunBullet = preload("res://Weapons/StunBullet.tscn")
onready var healBullet = preload("res://Weapons/HealBullet.tscn")
onready var fearBullet = preload("res://Weapons/FearBullet.tscn")
onready var muteBullet = preload("res://Weapons/MuteBullet.tscn")
onready var trapBullet = preload("res://Weapons/TrapBullet.tscn")
onready var slowBullet = preload("res://Weapons/SlowBullet.tscn")
onready var poisonBullet = preload("res://Weapons/PoisonBullet.tscn")
#Tipos movilidad
var dodge = "DODGE"
var teletransport = "TELETRANSPORT"
var reflect = "REFLECT"
var invisible = "INVISIBLE"
onready var buffTimer = $Effect
signal timeStart(timerName, fireRate)
signal movilityOver(type)

#INICIALIZACIONES Y BASICOS
func _ready():
	initializeStats()
	print(str(character), "-> HP: ", str(maxHealth), " / Speed: ", str(speed))
#Physics
func _physics_process(delta):
	get_Inputs() #Obtiene inputs de movimiento y accion
	look_at_mouse() #Comprueba donde esta el mouse para animar adecuadamente
	chooseAttacks(bullet, bigBullet, dodge) #Elige los ataques que se realizan segun character

#Inicializamos stats
func initializeStats():
	character = stats.character
	health = stats.health
	maxHealth = stats.maxHealth
	speed = stats.speed
	movilitySpeed = stats.movSpeed
	movilityRange = stats.movRange
	movilityDuration = stats.movDuration
	lifebar.max_value = maxHealth
	lifebar.value = health
	lifebarText.text = str(lifebar.value)
#FUNCIONES INPUTS
#Obtiene el input para hacer distintas acciones
#Se realizan las actualizaciones para los efectos que obtengamos
func get_Inputs():
	#Movimiento
	direction = Vector2(0,0)
	if Input.is_action_pressed("ui_left"):
		direction.x = -1
	if Input.is_action_pressed("ui_right"):
		direction.x = 1
	if Input.is_action_pressed("ui_up"):
		direction.y = -1
	if Input.is_action_pressed("ui_down"):
		direction.y = 1
	if state == DODGE:
		if startPoint.distance_to(self.global_position) < movilityRange: #Si estoy moviendome por debajo del rango maximo del jugador, puedo
			if startPoint.distance_to(self.global_position) < rangLength: #Si estoy moviendome por debajo del rango justo que queria, puedo
				direction = move_and_slide(directionMovility * movilitySpeed) #Nos movemos en la direccion
			else: #Y si no puedo, se acaba la animacion y pasamos a IDLE
				emit_signal("movilityOver", "DODGE")
		else:
				emit_signal("movilityOver", "DODGE")
		#Efectos
		blinkAnimationPlayer.play("StartWhite")
		hurtboxPlayer.set_deferred("monitoring", false) #Desactivamos el hurtbox del player al hacer voltereta
		hurtboxPlayer.set_deferred("visible", false) #Tambien la visibilidad solo para entenderlo mejor
	elif state == TELETRANSPORT:
		if startPoint.distance_to(self.global_position) < movilityRange: #Si estoy moviendome por debajo del rango maximo del jugador, puedo
			if startPoint.distance_to(self.global_position) < rangLength: #Si estoy moviendome por debajo del rango justo que queria, puedo
				direction = move_and_slide(directionMovility * movilitySpeed) #Nos movemos en la direccion
			else: #Y si no puedo, se acaba la animacion y pasamos a IDLE
				emit_signal("movilityOver", "TELETRANSPORT")
		else:
				emit_signal("movilityOver", "TELETRANSPORT")
		#Efectos
		hurtboxPlayer.set_deferred("monitoring", false) #Desactivamos el hurtbox del player al hacer voltereta
		hurtboxPlayer.set_deferred("visible", false) #Tambien la visibilidad solo para entenderlo mejor
		sprite.visible = false
	elif state == REFLECT:
		direction = direction.normalized()
		direction = move_and_slide(direction * movilitySpeed)
		#Efectos
		blinkAnimationPlayer.play("StartRed")
	elif state == INVISIBLE:
		direction = direction.normalized()
		direction = move_and_slide(direction * movilitySpeed)
		#Efectos
		blinkAnimationPlayer.play("StartBlue")
#		sprite.visible = false
	else:
		#Recuperamos velocidad normal
		direction = direction.normalized()
		direction = move_and_slide(direction * speed)
		#Recuperamos cambios que habiamos obtenido
		blinkAnimationPlayer.play("Stop")
		hurtboxPlayer.set_deferred("monitoring", true)#Reactivamos el hurtbox
		hurtboxPlayer.set_deferred("visible", true)
		sprite.visible = true
#Elegimos que weapon sale con cada boton, y que rate tiene
func chooseAttacks(firstAttack, secondAttack, movilityAction):
	if Input.is_action_pressed("MouseL"):
		shoot(firstAttack, stats.mlRate, attackRateML)
	if Input.is_action_pressed("MouseR"):
		shoot(secondAttack, stats.mrRate, attackRateMR)
	if Input.is_action_pressed("ButtonQ"):
		movility(movilityAction, stats.bqRate, attackRateBQ)

#El jugador siempre mira hacia el mouse, se mueva o no
#Se pueden cambiar las posiciones del pivot segun queramos que aparezcan las skills
#Primero comprueba que no hemos atacado, para decidir si estamos en movimiento o no, y animar lo que toque
func look_at_mouse():
	var mousePosition = get_global_mouse_position()
	if self.get_angle_to(mousePosition) > -0.75 and self.get_angle_to(mousePosition) < 0.75: #Derecha
		pivot.position = Vector2(5,0)
		if state == ATTACK:
			animationPlayer.play("attackBQRight")
		elif state == DODGE or state == TELETRANSPORT:
			animationPlayer.play("attackBQRight")
		else:
			if direction == Vector2(0,0):
				animationPlayer.play("idleRight")
			else:
				animationPlayer.play("moveRight")
	elif self.get_angle_to(mousePosition) > 2.25 and self.get_angle_to(mousePosition) < 3.15 or self.get_angle_to(mousePosition) < -2.25 and self.get_angle_to(mousePosition) > -3.15: #Izquierda
		pivot.position = Vector2(-5,0)
		if state == ATTACK:
			animationPlayer.play("attackBQLeft")
		elif state == DODGE or state == TELETRANSPORT:
			animationPlayer.play("attackBQLeft")
		else:
			if direction == Vector2(0,0):
				animationPlayer.play("idleLeft")
			else:
				animationPlayer.play("moveLeft")
	elif self.get_angle_to(mousePosition) > -2.25 and self.get_angle_to(mousePosition) < -0.75: #Arriba
		pivot.position = Vector2(0,-5)
		if state == ATTACK:
			animationPlayer.play("attackBQUp")
		elif state == DODGE or state == TELETRANSPORT:
			animationPlayer.play("attackBQUp")
		else:
			if direction == Vector2(0,0):
				animationPlayer.play("idleUp")
			else:
				animationPlayer.play("moveUp")
	elif self.get_angle_to(mousePosition) > 0.75 and self.get_angle_to(mousePosition) < 2.25: #Abajo
		pivot.position = Vector2(0,5)
		if state == ATTACK:
			animationPlayer.play("attackBQDown")
		elif state == DODGE or state == TELETRANSPORT:
			animationPlayer.play("attackBQDown")
		else:
			if direction == Vector2(0,0):
				animationPlayer.play("idleDown")
			else:
				animationPlayer.play("moveDown")
	#Esto hace una animacionde girar como si recargaras el arma sobre el dedo
	#get_node("Pivot/Weapon").rotation_degrees += 42

#FUNCIONES ATAQUES
#Necesita el punto al que disparar, el tipo de bala que queremos, stat fireRate skill, y nombre timer
func shoot(typeBullet, fireRate, timerName):
	direction = global_position.direction_to(get_global_mouse_position())
	if timerName.time_left == 0:
		#Instancia proyectil
		var bulletAttack = typeBullet.instance() #Instanciamos un nuevo arma
		get_parent().add_child(bulletAttack) #La asignamos al player
		bulletAttack.transform.origin = pivot.global_position #Indicamos posicion inicial que es la del AttackPosition
		bulletAttack.setDirection(direction) #Indicamos en que direccion debe ir
		timerName.start(fireRate) #Iniciamos el timer
		emit_signal("timeStart",timerName.name, fireRate) #Avisamos a los botones que inicien su timer
		#Cambiamos state a atacando para que se realice la animacion correspondiente
		state = ATTACK      
#Obtenemos la información del character para hacer modificaciones a las direcciones, velocidades y demas
func movility(type, fireRate, timerName):
	if type == "DODGE":
		if timerName.time_left == 0:
			startPoint = self.global_position
			directionMovility = (get_global_mouse_position() - startPoint)
			rangLength = directionMovility.length()
			directionMovility = directionMovility.normalized()
			
			#Effects and timers
#			immuneEffect = effectImmune.instance()
#			get_parent().add_child(immuneEffect)
#			immuneEffect.setCreator(character)
			timerName.start(fireRate)
			emit_signal("timeStart", timerName.name, fireRate)
			state = DODGE
	elif type == "TELETRANSPORT":
		if timerName.time_left == 0:
			startPoint = self.global_position
			directionMovility = (get_global_mouse_position() - startPoint)
			rangLength = directionMovility.length()
			directionMovility = directionMovility.normalized()
			
			#Effects and timers
			timerName.start(fireRate)
			emit_signal("timeStart", timerName.name, fireRate)
			state = TELETRANSPORT
	elif type == "REFLECT":
		if timerName.time_left == 0:
			
			#Effects and timers
#			immuneEffect = effectImmune.instance()
#			get_parent().add_child(immuneEffect)
#			immuneEffect.setCreator(character)
			timerName.start(fireRate)
			buffTimer.start(movilityDuration)
			emit_signal("timeStart", timerName.name, fireRate)
			state = REFLECT
	elif type == "INVISIBLE":
		if timerName.time_left == 0:
			
			#Effects and timers
#			immuneEffect = effectImmune.instance()
#			get_parent().add_child(immuneEffect)
#			immuneEffect.setCreator(character)
			timerName.start(fireRate)
			buffTimer.start(movilityDuration)
			emit_signal("timeStart", timerName.name, fireRate)
			state = INVISIBLE

#FUNCIONES DAÑO
func getHit(damage):
	#Texto flotante
	var text = floating_text.instance()
	text.amount = damage
	text.type = "Damage"
	add_child(text)
	#Recibimos daño
	health -= damage
	#Updateamos barras vida
	lifebar.value = health
	lifebarText.text = str(lifebar.value)
	#Si no queda vida, palmamos
	if health <= 0:
		queue_free()
#OTRAS FUNCIONES

#Para avisar que algo me ha tocado
func _on_Hurtbox_area_entered(area):
	if state == REFLECT:
		area.get_parent().setReflected()
		area.get_parent().setAttackChar()
	else:
		getHit(area.get_parent().getDamage())
		print("Something hit me. HP: ", health, "/", maxHealth)
#Funcion para que vuelva a la animacion basica tras acabar una animacion 
func _on_Player_movilityOver(type):
	state = IDLE
	if is_instance_valid(immuneEffect): #Comprobamos si existe, para no provocar fallos
			#Llamamos a que desaparezca la animacion de inmunidad cuando acaba la voltereta
			immuneEffect.emit_signal("isOver")
#Funcion por si cortamos la animacion a la mitad que se quite el efecto existente (En este caso solo hay immune)
func _on_AnimationPlayer_animation_finished(anim_name):
	state = IDLE
	if is_instance_valid(immuneEffect): #Comprobamos si existe, para no provocar fallos
			#Llamamos a que desaparezca la animacion de inmunidad cuando acaba la voltereta
			immuneEffect.emit_signal("isOver")

func _on_Effect_timeout():
	state = IDLE
