extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var appearead:bool = false
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	$animaciones.play("Appear")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():#Si presionas la tecla de saltar y estas en el suelo
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	#print(velocity)
	move_and_slide()
	decide_animation()
	
func decide_animation():
	if not appearead: return #No va a hacer caso de las animaciones a no ser que sea ese bool sea true
	#Eje de las X
	if velocity.x == 0:
		$animaciones.play("Idle")
		#Idle
	elif velocity.x < 0:
		#Izquierda - Left
		$animaciones.flip_h = true
		$animaciones.play("Run")
	elif velocity.x > 0:
		#Derecha - Right
		$animaciones.flip_h = false
		$animaciones.play("Run")
	#Eje de las y
	if velocity.y > 0:
		#Cayendo
		$animaciones.play("Jump_down")
	elif velocity.y < 0:
		#Saltando
		$animaciones.play("Jump_up")


func _on_animaciones_animation_finished():
	#print($animaciones.animation)
	if $animaciones.animation == "Appear":
		appearead = true
