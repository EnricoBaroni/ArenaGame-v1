extends Node2D

onready var animatedSprite = $AnimatedSprite
onready var duration = $Duration
var myCreator : String
#Señal para cuando queramos que acabe la animacion en cierto momento
signal isOver()

func _ready(): #Al crearse, se realiza la animacion
	animatedSprite.play("Animate")

func startTimer(time):
	duration.start(time)
#Para saber quien me ha instanciado, y asi detener los efectos solo en el
func setCreator(creator):
	myCreator = creator

func _on_StunEffect_isOver():
	get_parent().get_node(myCreator).emit_signal("effectOver", "Stun")
	queue_free()
#Cuando acaba el timer de duracion del stun, emitimos la señal de que se ha terminado, para que player recupere estado normal
func _on_Duration_timeout():
	get_parent().get_node(myCreator).emit_signal("effectOver", "Stun")
	queue_free()
