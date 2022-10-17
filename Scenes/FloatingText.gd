extends Position2D

onready var label = get_node("Label")
onready var tween = get_node("Tween")
var amount = 0
var type = "Damage"

var velocity = Vector2(0,0)
var max_size = Vector2(1,1)
var speedAway = 0.3

func _ready():
	#Setupeamos el texto segun la cantidad que le digamos
	label.set_text(str(amount))
	#Randomizamos hacia donde se mueve y a que velocidad
	randomize()
	var side_movement = randi() % 51 - 40
	velocity = Vector2(side_movement, 20)
	#Segun el tipo de texto que sea le damos distintas propiedades
	match type:
		"Heal":
			velocity = Vector2(0,10) #Hacemos que solo vaya hacia abajo el texto
			max_size = Vector2(1.5, 1.5) #Hacemos que el tamaño sea mas grande
			speedAway = 0.5 #Hacemos que la velocidad de irse sea mas lenta
			label.set("custom_colors/font_color", Color("2eff27"))
		"Damage":
			label.set("custom_colors/font_color", Color("ff3131"))
		"Poison":
			label.set("custom_colors/font_color", Color("940aa6"))
		"Critical":
			max_size = Vector2(1.5, 1.5)
			label.set("custom_colors/font_color", Color("eb721a"))
	#Efectuamos los ajustes al texto
	#Hace que desde la posicion self, aumente el tamaño a vector 1, en .2 sec, con los efectos, y viceversa en la segunda linea
	tween.interpolate_property(self, "scale", scale, max_size, 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(self, "scale", Vector2(1, 1), Vector2(0.1, 0.1), speedAway, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.3)
	tween.start()

func _process(delta):
	position += velocity * delta

func _on_Tween_tween_all_completed():
	self.queue_free()

