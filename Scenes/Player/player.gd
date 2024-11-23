extends CharacterBody2D


enum State {
	MOVE,
	ATTACK,
	ATTACK2,
	ATTACK3,
	BLOCK,
	SLIDE,
	DAMAGE,
	DEATH
}

const SPEED = 150.0
const JUMP_VELOCITY = -400.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animPlayer = $AnimationPlayer
@onready var pointLight = $PointLight2D
@onready var stats = $Stats


var state = State.MOVE
var run_speed = 1
var combo = false
var attack_cooldown = false
var player_alive
var damage_basic = 10
var damage_multiplayer = 1
var damage_current
var recovery = false

func _ready():
	Signals.connect("enemy_attack", Callable (self, "_on_damage_recived"))

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	if velocity.y > 0:
		animPlayer.play("Fall")
		
	Global.player_damage = damage_basic * damage_multiplayer


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
		State.DAMAGE:
			damage_state()
		State.DEATH:
			death_state()
			
			
	move_and_slide()
	
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	Global.player_pos = self.position

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
		$AnimatedSprite2D.flip_h = true
		$AttackDirection.rotation_degrees = 180
	elif direction == 1:
		$AnimatedSprite2D.flip_h = false
		$AttackDirection.rotation_degrees = 0
		
	if Input.is_action_pressed("run") and not recovery:
		run_speed = 2
		stats.stamina -= stats.run_cost
	else:
		run_speed = 1
		
		
	if Input.is_action_just_pressed("attack"):
		if not recovery:
			stats.stamina_cost = stats.attack_cost
			if attack_cooldown == false and stats.stamina > stats.stamina_cost:
				state = State.ATTACK
			
	if Input.is_action_just_pressed("slide") and velocity.x != 0:
		if not recovery:
			stats.stamina_cost = stats.slide_cost
			if stats.stamina > stats.stamina_cost:
				state = State.SLIDE
			
	elif Input.is_action_pressed("block") and velocity.x == 0:
		if not recovery:
			if stats.stamina > 1:
				state = State.BLOCK
	
	
func block_state():
	stats.stamina -= stats.block_cost
	velocity.x = move_toward(velocity.x, 0, SPEED)
	animPlayer.play("Block")
	if Input.is_action_just_released("block") or recovery == true:
		state = State.MOVE

func slide_state():
	animPlayer.play("Slide")
	await animPlayer.animation_finished
	state = State.MOVE
	
func death_state():
	velocity.x = 0
	animPlayer.play("Death")
	await animPlayer.animation_finished
	queue_free()
	get_tree().change_scene_to_file.bind("res://Scenes/menu/menu.tscn").call_deferred()
	
func attack_state():
	stats.stamina_cost = stats.attack_cost
	damage_multiplayer = 1
	if Input.is_action_just_pressed("attack") and combo == true and stats.stamina > stats.stamina_cost:
		state = State.ATTACK2
	velocity.x = move_toward(velocity.x, 0, SPEED)
	animPlayer.play("Attack")
	await animPlayer.animation_finished
	state = State.MOVE

func attack2_state():
	stats.stamina_cost = stats.attack_cost
	damage_multiplayer = 1.2
	if Input.is_action_just_pressed("attack") and combo == true and stats.stamina > stats.stamina_cost:
		state = State.ATTACK3
	animPlayer.play("Attack2")
	await animPlayer.animation_finished
	state = State.MOVE

func attack3_state():
	stats.stamina_cost = stats.attack_cost
	damage_multiplayer = 2
	animPlayer.play("Attack3")
	await animPlayer.animation_finished
	state = State.MOVE

func combo_attack():
	combo = true
	await animPlayer.animation_finished
	combo = false
	
func attack_freeze():
	attack_cooldown = true
	await get_tree().create_timer(0.5).timeout
	attack_cooldown = false

func damage_state():
	animPlayer.play("Damage")
	await animPlayer.animation_finished
	state = State.MOVE

func _on_damage_recived(enemy_damage):
	if state == State.BLOCK:
		enemy_damage /= 2
	elif state == State.SLIDE:
		enemy_damage = 0
	else:
		state = State.DAMAGE
		damage_anim()
	stats.health -= enemy_damage
	if stats.health <= 0:
		stats.health = 0
		state = State.DEATH
	

func _on_stats_no_stamina():
	recovery = true
	await get_tree().create_timer(2).timeout
	recovery = false
	
	
func damage_anim():
	velocity.x = 0
	self.modulate = Color(1,0,0,1)
	if $AnimatedSprite2D.flip_h == true:
		velocity.x += 200
	else:
		velocity.x -= 200
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(self, "velocity", Vector2.ZERO, 0.2)
	tween.parallel().tween_property(self, "modulate", Color(1,1,1,1), 0.2)
