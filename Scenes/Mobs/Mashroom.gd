extends CharacterBody2D

@onready var animPlayer = $AnimationPlayer

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		
	move_and_slide()


func _on_attack_range_body_entered(_body):
	animPlayer.play("Attack")
