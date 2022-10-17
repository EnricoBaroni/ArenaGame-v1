extends Node2D

onready var animatedSprite = $AnimatedSprite
onready var duration = $Duration
#Señal para cuando queramos que acabe la animacion en cierto momento
signal isOver()

func _ready(): #Al crearse, se realiza la animacion
	animatedSprite.play("Animate")

func startTimer(time):
	duration.start(time)

func _on_Duration_timeout():
	queue_free()

func _on_HealEffect_isOver():
	queue_free()
