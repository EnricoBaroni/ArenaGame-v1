extends KinematicBody2D

#INICIALIZACIONES Y VARIABLES
#Stats
var character
var health
var maxHealth
var speed
#TEXTO FLOTANTE
var floating_text = preload("res://Scenes/FloatingText.tscn")
#Onreadys
onready var stats : Stats = $Stats
onready var hurtbox = $Hurtbox
onready var lifebar = $Lifebar
onready var lifebarText = $Lifebar/LifebarText
onready var effectPosition = $EffectPosition
onready var myEffectTimer = $Effect
#Carga animaciones efectos
var effectHit = load("res://Effects/HitEffect.tscn")
var effectImmune = load("res://Effects/Immune2Effect.tscn")
var effectStun = load("res://Effects/StunEffect.tscn")
var effectHeal = load("res://Effects/Heal2Effect.tscn")
var effectPoison = load("res://Effects/PoisonEffect.tscn")
var effectSlow = load("res://Effects/SlowEffect.tscn")
var effectTrap = load("res://Effects/TrapEffect.tscn")
var effectMute = load("res://Effects/MuteEffect.tscn")
var effectFear = load("res://Effects/FearEffect.tscn")
#Otras variables
onready var bullet = preload("res://Weapons/Bullet.tscn")
onready var attackRate = $AttackRateML
onready var pivot = $AttackPosition
var velocity = Vector2.ZERO
var directionShoot = Vector2.ZERO
var directionMove = Vector2.ZERO
var moved = 0
var moveRight = true
var movingEffect = false
var poisonTicks 
var tickDamage
var objectiveCharacter
var hasRunned = false
#Effects
var healEffect
var slowEffect
var stunEffect
var trapEffect
var muteEffect
var fearEffect
var poisonEffect
var myEffects : Array
#Señal efectos
signal effectOver(effectName)
signal tickOver()
signal objectiveChanged(character)

## INICIO ##
func _ready():
	initializeStats()
	myEffects.clear()
func _physics_process(delta):
#	pass
	movingEffect() #Mover cuadros efectos
	if myEffects.find("Stun") == -1:
		if myEffects.find("Fear") != -1:
			runAway()
		else:
			if myEffects.find("Trap") == -1:
				movePracticeChar() #Mover muñeco
			if myEffects.find("Mute") == -1:
				shoot(objectiveCharacter, bullet, stats.mlRate, attackRate) #Atacar al player

func initializeStats():
	character = stats.character
	health = stats.health
	maxHealth = stats.maxHealth
	speed = stats.speed
	lifebar.max_value = maxHealth
	lifebar.value = health
	lifebarText.text = str(maxHealth)

## MUÑECO ##
#Para que se mueva el muñeco de izq a dcha
func movePracticeChar(): 
	if speed != 0:
		moved += 1
	if moveRight:
		directionMove = Vector2.RIGHT
		if moved == 100:
			moveRight = false
			moved = 0
	elif moveRight == false:
		directionMove = Vector2.LEFT
		if moved == 100:
			moveRight = true
			moved = 0
	velocity = move_and_slide(directionMove * speed) #Asignamos velocidad y direccion y nos movemos
#Para que huya del personaje en direccion contraria
func runAway():
	if hasRunned == false:
		directionMove = global_position.direction_to(objectiveCharacter.global_position)
		hasRunned = true
	velocity = move_and_slide(-directionMove * speed)
#Disparando al jugador
func shoot(point, typeBullet, fireRate, timerName):
	if is_instance_valid(point):
		directionShoot = global_position.direction_to(point.global_position)
		if timerName.time_left == 0:
			var bulletAttack = typeBullet.instance() #Instanciamos un nuevo arma
			get_parent().add_child(bulletAttack) #La asignamos al player
			bulletAttack.transform.origin = pivot.global_position
			bulletAttack.scale = scale * 1.5
			bulletAttack.setDirection(directionShoot) #Indicamos en que direccion debe ir
			bulletAttack.setAttackPlayer()
			timerName.start(fireRate)

## EFECTOS ##
#Aqui se recibira la info de que he recibido un efecto nuevo
#Se pondra un orden de prioridad para que solo afecte el mas potente
#Se genera la animacion aqui?
#En el codigo de stats se realizan las operaciones y llamadas segun lo que quiera
#En los efectos duracion iniciaremos un timer extra, para volver al estado normal cuando acabe
func getEffect(typeBullet, duration, quantity, effectType):
	var text = floating_text.instance()
	text.amount = quantity
	if typeBullet == "Bullet": #Afecta health: -quantity
		text.type = "Damage" #Indicamos texto flotante 
		myEffects.append("None") #Indicamos efecto estamos
		
		health = stats.takeDamage(quantity) #Recibimos efecto daño
		#No effects so nothing else here
		
	elif typeBullet == "BigBullet": #Afecta health y speed: -quantity *effectType
		text.type = "Damage" #Indicamos texto flotante
		myEffects.append("Slow") #Indicamos efecto estamos
		#Animaciones
		slowEffect = effectSlow.instance() #Hacemos la animacion
		get_parent().add_child(slowEffect)
		slowEffect.setCreator(character)
		slowEffect.startTimer(duration)
		movingEffect = true #Para que se actualice la posicion en movimiento
		myEffectTimer.start(duration) #Iniciamos timer duracion efecto
		#Efectos
		health = stats.takeDamage(quantity) #Recibimos efecto daño
		speed = stats.takeSlow(effectType) #Recibimos efecto slow
		
	elif typeBullet == "HealBullet": #Afecta health
		text.type = "Heal" #Indicamos que tipo de texto flotante mostramos
		myEffects.append("Heal")
		
		healEffect = effectHeal.instance() #Hacemos la animacion
		get_parent().add_child(healEffect)
		healEffect.setCreator(character) #Con esto cuando acabe el efecto nos aplicara solo a nosotros
		healEffect.startTimer(duration)
		movingEffect = true #Para que se actualice la posicion en movimiento
		myEffectTimer.start(duration) #Iniciamos timer duracion efecto
		
		health = stats.takeHeal(quantity) #Recibimos el efecto
		
	elif typeBullet == "StunBullet": #Afecta speed y capacidades
		myEffects.append("Stun")
		
		stunEffect = effectStun.instance()
		get_parent().add_child(stunEffect)
		stunEffect.setCreator(character)
		stunEffect.startTimer(duration)
		movingEffect = true
		myEffectTimer.start(duration)
		
		speed = stats.takeStun(effectType)
		
	elif typeBullet == "TrapBullet": #Afecta speed
		myEffects.append("Trap")
		
		trapEffect = effectTrap.instance()
		get_parent().add_child(trapEffect)
		trapEffect.setCreator(character)
		trapEffect.startTimer(duration)
		movingEffect = true
		myEffectTimer.start(duration)
		
		speed = stats.takeTrap(effectType)
		
	elif typeBullet == "SlowBullet": #Afecta speed
		myEffects.append("Slow")
		
		slowEffect = effectSlow.instance()
		get_parent().add_child(slowEffect)
		slowEffect.setCreator(character)
		slowEffect.startTimer(duration)
		movingEffect = true
		myEffectTimer.start(duration)
		
		speed = stats.takeSlow(effectType)
		
	elif typeBullet == "PoisonBullet": #Afecta health. effect type es daño total, que se dividira entre duracion para ver cuanto quita cada tick
		myEffects.append("Poison")
		
		poisonEffect = effectPoison.instance()
		get_parent().add_child(poisonEffect)
		poisonEffect.setCreator(character) 
		poisonEffect.startTimer(duration)
		movingEffect = true
		myEffectTimer.start(duration)
		
		poisonTicks = duration #Los ticks de daño que va a hacer el poison
		tickDamage = effectType / duration #Cuanto daño va a hacer cada tick
		takePoison(poisonEffect) #Llamamos la funcion que hara daño segun toque
		
	elif typeBullet == "FearBullet": #Afecta capacidades
		myEffects.append("Fear")
		
		fearEffect = effectFear.instance()
		get_parent().add_child(fearEffect)
		fearEffect.setCreator(character)
		fearEffect.startTimer(duration)
		movingEffect = true
		myEffectTimer.start(duration)
		
	elif typeBullet == "MuteBullet": #Afecta capacidades
		myEffects.append("Mute")
		
		muteEffect = effectMute.instance()
		get_parent().add_child(muteEffect)
		muteEffect.setCreator(character)
		muteEffect.startTimer(duration)
		movingEffect = true
		myEffectTimer.start(duration)
		
	#Añadimos floating text, solo si es distinto de 0, osea solo si es daño
	if text.amount != 0:
		add_child(text)
	#Updateamos barras de vida
	lifebar.value = stats.health
	lifebarText.text = str(lifebar.value)

func takePoison(poisonEffect):
	if poisonTicks > 0: #Si aun quedan ticks por realizarse, recibimos daño, sale texto
			health = stats.takePoison(tickDamage) #Hacemos daño
			lifebar.value = stats.health #Updateamos barras vida
			lifebarText.text = str(lifebar.value)
			var textTick = floating_text.instance() #Añadimos floating text
			textTick.type = "Poison"
			textTick.amount = tickDamage
			add_child(textTick)
			poisonTicks -= 1
			poisonEffect.startTick(1, poisonTicks) #Iniciamos contador de cada cuanto hace tick de veneno
			
	else:
		poisonEffect.emit_signal("isOver")
#Para que se sigan moviendo los cuadrados de efecto (Solo estos por que los demas clavan al jugador)
func movingEffect():
	if movingEffect: 
		if is_instance_valid(slowEffect):
			slowEffect.position = effectPosition()
	if movingEffect: 
		if is_instance_valid(healEffect):
			healEffect.position = effectPosition()
	if movingEffect: 
		if is_instance_valid(poisonEffect):
			poisonEffect.position = effectPosition()
	if movingEffect: 
		if is_instance_valid(fearEffect):
			fearEffect.position = effectPosition()
	if movingEffect: 
		if is_instance_valid(stunEffect):
			stunEffect.position = effectPosition()
	if movingEffect: 
		if is_instance_valid(trapEffect):
			trapEffect.position = effectPosition()
	if movingEffect: 
		if is_instance_valid(muteEffect):
			muteEffect.position = effectPosition()

#Devuelve la posicion donde colocar las animaciones de efectos
func effectPosition():
	return effectPosition.global_position

#Cuando algo entra a mi area detecto que tipo de arma es (Solo detecto weapons asi que siempre tendran daño u otros efectos)
func _on_Hurtbox_area_entered(area): 
	var bullet = area.get_parent() #Detecto que bala ha entrado
	getEffect(bullet.getName(), bullet.getDuration(), bullet.getDamage(), bullet.getEffectType()) #Enviamos a que se haga lo que toque segun el efecto

func _on_Stats_health_depleted():
	var hitEffect = effectHit.instance() #Instanciamos
	get_parent().add_child(hitEffect) #La añadimos a la escena
	hitEffect.position = self.position #Hacemos que aparezca encima de lo que golpeamos
	hitEffect.setScale(2)
	hitEffect.setSpeedScale(0.25)
	queue_free()

func _on_PracticeChar_effectOver(effectName):
	if effectName == "Stun": #Recuperamos speed y facultades
		myEffects.erase("Stun")
		speed = stats.recoverSpeed()
	elif effectName == "Slow": #Recuperamos speed
		myEffects.erase("Slow")
		speed = stats.recoverSpeed()
	elif effectName == "Trap": #Recuperamos speed
		myEffects.erase("Trap")
		speed = stats.recoverSpeed()
	elif effectName == "Poison": #Recuperamos capacidades
		myEffects.erase("Poison")
	elif effectName == "Mute": #Recuperamos capacidades
		myEffects.erase("Mute")
	elif effectName == "Invisible": #Recuperamos visibilidad
		myEffects.erase("Invisible")
	elif effectName == "Immune": #Recuperamos hitbox
		myEffects.erase("Immune")
	elif effectName == "Fear": #Recuperamos facultades
		hasRunned = false
		myEffects.erase("Fear")
	elif effectName == "Reflect": #Recuperamos facultades
		myEffects.erase("Reflect")

#Llama desde poisoneffect mientras queden ticks de poison por ejecutarse
func _on_PracticeChar_tickOver(): 
	takePoison(poisonEffect)
#Cuando cambiamos de muñeco en selector, se reasigna objetivo
func _on_PracticeChar_objectiveChanged(character):
	objectiveCharacter = character
