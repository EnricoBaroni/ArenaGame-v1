extends Node2D

onready var animatedSprite = $AnimatedSprite
onready var duration = $Duration
onready var tick = $Tick
var ticksLeft
var myCreator : String
#Señal para cuando queramos que acabe la animacion en cierto momento
signal isOver()

func _ready(): #Al crearse, se realiza la animacion
	animatedSprite.play("Animate")

func startTimer(time):
	duration.start(time)
func startTick(time, ticks):
	tick.start(time)
	ticksLeft = ticks
#Para saber quien me ha instanciado, y asi detener los efectos solo en el
func setCreator(creator):
	myCreator = creator

func _on_PoisonEffect_isOver(): #Por si queremos cortarlo antes
	get_parent().get_node(myCreator).emit_signal("effectOver", "Poison")
	queue_free()

func _on_Tick_timeout():
	if get_parent().get_node(myCreator) != null:
		get_parent().get_node(myCreator).emit_signal("tickOver")
	else:
		queue_free()
