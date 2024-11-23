extends CharacterBody2D

enum State {
	IDLE,
	ATTACK,
	CHASE,
	DAMAGE,
	DEATH,
	RECOVER
	
}
var state: int = 0:
	set(value):
		state = value
		match state:
			State.IDLE:
				idle_state()
			State.ATTACK:
				attack_state()
			State.DAMAGE:
				damage_state()
			State.DEATH:
				death_state()
			State.RECOVER:
				recover_state()

@onready var animPlayer = $AnimationPlayer
@onready var sprite = $AnimatedSprite2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player
var direction
var damage = 20


func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		
	if state == State.CHASE:
		chase_state()
		
	move_and_slide()
	player = Global.player_pos

func _on_attack_range_body_entered(_body):
	state = State.ATTACK

func idle_state():
	animPlayer.play("Idle")
	state = State.CHASE
	
func attack_state():
	animPlayer.play("Attack")
	await animPlayer.animation_finished
	state = State.RECOVER

func chase_state():
	direction = (player - self.position).normalized()
	if direction.x < 0:
		sprite.flip_h = true
		$AttackDirection.rotation_degrees = 180
	else:
		sprite.flip_h = false
		$AttackDirection.rotation_degrees = 0
		
func damage_state():
	damage_anim()
	animPlayer.play("Damage")
	await animPlayer.animation_finished
	state = State.IDLE

func death_state():
	Signals.emit_signal("enemy_died", position)
	animPlayer.play("Death")
	await animPlayer.animation_finished
	queue_free()
	
func recover_state():
	animPlayer.play("Recover")
	await animPlayer.animation_finished
	state = State.IDLE

func _on_hit_box_area_entered(_area):
	Signals.emit_signal("enemy_attack", damage)

func _on_mob_health_no_health():
	state = State.DEATH


func _on_mob_health_damage_received():
	state = State.IDLE
	state = State.DAMAGE
	
	
func damage_anim():
	direction = (player - self.position).normalized()
	velocity.x = 0
	if direction.x < 0:
		velocity.x += 200
	elif direction.x > 0:
		velocity.x -= 200
	var tween = get_tree().create_tween()
	tween.tween_property(self, "velocity", Vector2.ZERO, 0.1)
	
