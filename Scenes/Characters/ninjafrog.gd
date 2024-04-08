extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -450.0
var allow_animation:bool = false
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var leaved_floor: bool = false
var had_jump: bool = false
var max_jumps: int = 2
var count_jumps: int = 0
var double_jump:bool = false
var ray_cast_dimension = 10.5

func _ready():
	$animaciones.play("Appear")
	$raycast_wall_jump.target_position.x = ray_cast_dimension

func _physics_process(delta):
	if is_on_floor(): # SI tocas suelos o mejor dicho si vuelves a tocar suelo
		leaved_floor = false
		had_jump = false
		count_jumps = 0
	# Add the gravity.
	if not is_on_floor():#si no estoy en el suelo
		if not leaved_floor:#Si no he dejado el suelo
			$Coyote_timer.start()
			leaved_floor = true #he dejado el suelo
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and right_to_jump():#Si presionas la tecla de saltar y se cumple lo demas
		if count_jumps == 1:
			double_jump = true
		count_jumps += 1 
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
	print($raycast_wall_jump.get_collider())
	if $raycast_wall_jump.get_collider():
		if $raycast_wall_jump.get_collider().is_in_group("wall_jump"):
			print("Tocando la zona amarilla")
func decide_animation():
	if double_jump:
		double_jump = false
		allow_animation = false
		if velocity.x < 0:
			$animaciones.flip_h = true
		elif velocity.x > 0:
			$animaciones.flip_h = false
		
		$animaciones.play("Double_jump")
	if not allow_animation: return #No va a hacer caso de las animaciones a no ser que sea ese bool sea true
	#Eje de las X
	if velocity.x == 0:
		$animaciones.play("Idle")
		#Idle
	elif velocity.x < 0:
		#Izquierda - Left
		$raycast_wall_jump.target_position.x = -ray_cast_dimension
		$animaciones.flip_h = true
		$animaciones.play("Run")
	elif velocity.x > 0:
		#Derecha - Right
		$raycast_wall_jump.target_position.x = ray_cast_dimension
		$animaciones.flip_h = false
		$animaciones.play("Run")
	#Eje de las y
	if velocity.y > 0:
		#Cayendo
		$animaciones.play("Jump_down")
	elif velocity.y < 0:
		#Saltando
		$animaciones.play("Jump_up")

func right_to_jump():
	if had_jump: 
		if count_jumps < max_jumps: return true
		else: return false
	if is_on_floor(): 
		had_jump = true
		return true
	elif not $Coyote_timer.is_stopped():
		had_jump = true
		return true


#Señales
func _on_animaciones_animation_finished():
	#print($animaciones.animation)
	allow_animation = true


func _on_coyote_timer_timeout():
	print("Boom")
