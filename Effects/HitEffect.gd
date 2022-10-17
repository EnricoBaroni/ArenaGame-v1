extends Node2D

onready var animatedSprite = $AnimatedSprite
onready var duration = $Duration
#Señal para cuando queramos que acabe la animacion en cierto momento
signal isOver()

func _ready(): #Al crearse, se realiza la animacion
	animatedSprite.play("Animate")

func startTimer(time):
	duration.start(time)
func setScale(boost):
	animatedSprite.scale = animatedSprite.scale * boost
func setSpeedScale(boost):
	animatedSprite.speed_scale = animatedSprite.speed_scale * boost
#Cuando acaba la animacion, desaparece
func _on_AnimatedSprite_animation_finished():
	queue_free()

func _on_HitEffect_isOver():
	queue_free()

func _on_Duration_timeout():
	queue_free()
