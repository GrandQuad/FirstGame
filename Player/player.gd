extends CharacterBody2D

enum State {
	MOVE,
	ATTACK,
	ATTACK2,
	ATTACK3,
	BLOCK,
	SLIDE,
	DEAD
}

const SPEED = 150.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var anim = $AnimatedSprite2D
@onready var animPlayer = $AnimationPlayer
@onready var pointLight = $PointLight2D

var health = 100
var gold = 0
var state = State.MOVE
var run_speed = 1
var combo = false

func _physics_process(delta):
	if health <= 0 and state != State.DEAD:
		state = State.DEAD
		health = 0
		animPlayer.play("Death")
		return

	match state:
		State.MOVE:
			move_state()
		State.ATTACK:
			attack_state()
		State.ATTACK2:
			attack2_state()
		State.ATTACK3:
			attack3_state()
		State.BLOCK:
			block_state()
		State.SLIDE:
			slide_state()
		State.DEAD:
			if animPlayer.is_playing() and animPlayer.current_animation == "Death":
				return
			else:
				queue_free()
				get_tree().change_scene_to_file("res://menu.tscn")
			
	if state != State.DEAD:
		if not is_on_floor():
			velocity.y += gravity * delta
	
		if Input.is_action_just_pressed("Jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
			animPlayer.play("Jump")

		if velocity.y > 0:
			animPlayer.play("Fall")
		
		move_and_slide()

func move_state():
	var direction = Input.get_axis("left", "right")
	if direction != 0:
		velocity.x = direction * SPEED * run_speed
		if is_on_floor():
			if run_speed == 1:
				animPlayer.play("Walk")
			else:
				animPlayer.play("Run")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor():
			animPlayer.play("Idle")
	
	if direction == -1: 
		anim.flip_h = true
	elif direction == 1:
		anim.flip_h = false
		
	if Input.is_action_pressed("run"):
		run_speed = 2
	else:
		run_speed = 1
		
	if Input.is_action_pressed("block"):
		if velocity.x == 0:
			state = State.BLOCK
		else: 
			state = State.SLIDE
	
	if Input.is_action_just_pressed("attack"):
		state = State.ATTACK
	
func block_state():
	velocity.x = 0
	animPlayer.play("Block")
	if Input.is_action_just_released("block"):
		state = State.MOVE

func slide_state():
	animPlayer.play("Slide")
	await animPlayer.animation_finished
	state = State.MOVE

func attack_state():
	if Input.is_action_just_pressed("attack") and combo == true:
		state = State.ATTACK2
	velocity.x = 0
	animPlayer.play("Attack")
	await animPlayer.animation_finished
	state = State.MOVE

func attack2_state():
	if Input.is_action_just_pressed("attack") and combo == true:
		state = State.ATTACK3
	animPlayer.play("Attack2")
	await animPlayer.animation_finished
	state = State.MOVE

func attack3_state():
	animPlayer.play("Attack3")
	await animPlayer.animation_finished
	state = State.MOVE

func combo_attack():
	combo = true
	await animPlayer.animation_finished
	combo = false
