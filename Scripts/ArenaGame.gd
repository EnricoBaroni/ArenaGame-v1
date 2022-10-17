extends Node2D
class_name ArenaGame
#Onreadys interface
onready var remoteT = $PlayerGunner/RemoteTransform2D
onready var generatePosition = $GeneratePosition
onready var mouseL = $Interface/UI/MouseL
onready var mouseR = $Interface/UI/MouseR
onready var buttonQ = $Interface/UI/ButtonQ
onready var characterSelect = $Interface/UI/CharacterSelect
onready var timerML = $Interface/UI/MouseL/TimerML
onready var timerMR = $Interface/UI/MouseR/TimerMR
onready var timerBQ = $Interface/UI/ButtonQ/TimerBQ
#Onreadys carga personajes
onready var charGunner = preload("res://Characters/PlayerGunner.tscn")
onready var charHealer = preload("res://Characters/PlayerHealer.tscn")
onready var charWarrior = preload("res://Characters/PlayerWarrior.tscn")
onready var charMage = preload("res://Characters/PlayerMage.tscn")
#Onreadys llamada personajes
onready var gunnerPlayer = $PlayerGunner
var healerPlayer 
var warriorPlayer 
var magePlayer 
#Checks cambio personaje
onready var newPlayer = gunnerPlayer #Quien es el personaje en uso
onready var lastPlayerUsed = gunnerPlayer #Para comprobar a quien quitarle el remote
onready var lastPlayerUsedName = "gunnerPlayer"
#Muñeco practicas
onready var practiceChar = $PracticeChar
func _ready():
	setConnections()
	practiceChar.emit_signal("objectiveChanged", newPlayer)

func _physics_process(delta):
	setButtonTimers()
#Para obtener el nodo de personaje que queramos al cambiar
func getCharacterNode(character):
	if character == "Gunner":
		gunnerPlayer = $PlayerGunner
	elif character == "Healer":
		healerPlayer = $PlayerHealer
	elif character == "Warrior":
		warriorPlayer = $PlayerWarrior
	elif character == "Mage":
		magePlayer = $PlayerMage

func setConnections():
	if lastPlayerUsedName == "gunnerPlayer":
		gunnerPlayer.connect("timeStart", self, "timeStarted")
	elif lastPlayerUsedName == "healerPlayer":
		healerPlayer.connect("timeStart", self, "timeStarted")
	elif lastPlayerUsedName == "warriorPlayer":
		warriorPlayer.connect("timeStart", self, "timeStarted")
	elif lastPlayerUsedName == "magePlayer":
		magePlayer.connect("timeStart", self, "timeStarted")
#Pone el cooldown de las habilidades en tiempo real
func setButtonTimers():
#	if is_instance_valid(timerML && timerMR && timerBQ):
		if timerML.time_left > 0:
			mouseL.text = str(stepify(timerML.time_left, 0.1))
		if timerMR.time_left > 0:
			mouseR.text = str(stepify(timerMR.time_left, 0.1))
		if timerBQ.time_left > 0:
			buttonQ.text = str(stepify(timerBQ.time_left, 0.1))


#SELECCION PERSONAJE
#Se abre menu seleccion
func _on_Character_pressed():
	characterSelect.popup()
#Segun el que pulsemos, cargamos ese character
func _on_CharacterSelect_id_pressed(id):
	if is_instance_valid(newPlayer):
		if newPlayer != null: #Si ya existia un personaje, lo borramos
			newPlayer.queue_free()
		for n in characterSelect.get_item_count(): #Limpiamos todos los que habia antes
			characterSelect.set_item_checked(n, false)
			characterSelect.set_item_disabled(n, false)
		if id == 0: #Gunner
			print("Gunner chosen") #Decimos cual hemos elegido
			newPlayer = charGunner.instance() #Elegimos que character
			self.add_child(newPlayer) #Añadimos el character
			newPlayer.transform.origin = generatePosition.global_position #Hacemos que aparezca en el centro
			#QUE HACER CON EL PLAYER REAL DE DEBAJO
			lastPlayerUsed.remove_child(remoteT)
			newPlayer.add_child(remoteT)
			lastPlayerUsed = newPlayer
			lastPlayerUsedName = "gunnerPlayer"
			getCharacterNode("Gunner")
			#Set up interfaces
			characterSelect.set_item_checked(0, true) #Marcamos cual ha sido nuestra seleccion
			characterSelect.set_item_disabled(0, true)
			#Enviar al muñeco pa que apunte
			practiceChar.emit_signal("objectiveChanged", newPlayer)
		elif id == 1: #Healer
			print("Healer chosen") #Decimos cual hemos elegido
			newPlayer = charHealer.instance() #Elegimos que character
			self.add_child(newPlayer) #Añadimos el character
			newPlayer.transform.origin = generatePosition.global_position #Hacemos que aparezca en el centro
			#QUE HACER CON EL PLAYER REAL DE DEBAJO
			lastPlayerUsed.remove_child(remoteT)
			newPlayer.add_child(remoteT)
			lastPlayerUsed = newPlayer
			lastPlayerUsedName = "healerPlayer"
			getCharacterNode("Healer")
			#Set up interfaces
			characterSelect.set_item_checked(1, true)
			characterSelect.set_item_disabled(1, true)
			#Enviar al muñeco pa que apunte
			practiceChar.emit_signal("objectiveChanged", newPlayer)
		elif id == 2: #Warrior
			print("Warrior chosen") #Decimos cual hemos elegido
			newPlayer = charWarrior.instance() #Elegimos que character
			self.add_child(newPlayer) #Añadimos el character
			newPlayer.transform.origin = generatePosition.global_position #Hacemos que aparezca en el centro
			#QUE HACER CON EL PLAYER REAL DE DEBAJO
			lastPlayerUsed.remove_child(remoteT)
			newPlayer.add_child(remoteT)
			lastPlayerUsed = newPlayer
			lastPlayerUsedName = "warriorPlayer"
			getCharacterNode("Warrior")
			#Set up interfaces
			characterSelect.set_item_checked(2, true)
			characterSelect.set_item_disabled(2, true)
			#Enviar al muñeco pa que apunte
			practiceChar.emit_signal("objectiveChanged", newPlayer)
		elif id == 3: #Mage
			print("Mage chosen") #Decimos cual hemos elegido
			newPlayer = charMage.instance() #Elegimos que character
			self.add_child(newPlayer) #Añadimos el character
			newPlayer.transform.origin = generatePosition.global_position #Hacemos que aparezca en el centro
			#QUE HACER CON EL PLAYER REAL DE DEBAJO
			lastPlayerUsed.remove_child(remoteT)
			newPlayer.add_child(remoteT)
			lastPlayerUsed = newPlayer
			lastPlayerUsedName = "magePlayer"
			getCharacterNode("Mage")
			#Set up interfaces
			characterSelect.set_item_checked(3, true)
			characterSelect.set_item_disabled(3, true)
			#Enviar al muñeco pa que apunte
			practiceChar.emit_signal("objectiveChanged", newPlayer)
		resetButtonTimers() #Para que los cooldowns se restablezcan
		setConnections()

func timeStarted(timerName, fireRate):
	if timerName == "AttackRateML":
		timerML.start(fireRate)
	elif timerName == "AttackRateMR":
		timerMR.start(fireRate)
	elif timerName == "AttackRateBQ":
		timerBQ.start(fireRate)

#Si se acaban los timers de cooldown se vuelve a poner la letra, meter aqui animaciones futuras indicar fin cooldown
func _on_TimerML_timeout():
	mouseL.text = "ML"
	mouseL.disabled = false
func _on_TimerMR_timeout():
	mouseR.text = "MR"
	mouseR.disabled = false
func _on_TimerBQ_timeout():
	buttonQ.text = "Q"
	buttonQ.disabled = false
#Para llamar en algun momento y que todos los numeros desaparezcan
func resetButtonTimers():
	timerML.stop()
	timerMR.stop()
	timerBQ.stop()
	mouseL.text = "ML"
	mouseR.text = "MR"
	buttonQ.text = "Q"
#Boton para salir del juego
func _on_Exit_pressed():
	get_tree().quit()
