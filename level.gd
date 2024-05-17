extends Node2D

@onready var light = $DirectionalLight2D
@onready var pointLight = $PointLight2D
@onready var pointLight2 = $PointLight2D2
@onready var pointLight3 = $PointLight2D3

enum State {
	MORNING,
	EVENING,
	DAY,
	NIGHT
}

var state = State.MORNING

func _ready():
	light.enabled = true

func _process(_delta):
	match state:
		State.MORNING:
			morning_state()
		State.EVENING:
			evening_state()

func morning_state():
	var tween = get_tree().create_tween()
	tween.tween_property(light, "energy", 0.2, 20)
	
	var tween1 = get_tree().create_tween()
	tween1.tween_property(pointLight, "energy", 0, 20)
	
	var tween2 = get_tree().create_tween()
	tween2.tween_property(pointLight2, "energy", 0, 20)
	
	var tween3 = get_tree().create_tween()
	tween3.tween_property(pointLight3, "energy", 0, 20)
	

func evening_state():
	var tween = get_tree().create_tween()
	tween.tween_property(light, "energy", 0.95, 20)
	
	var tween1 = get_tree().create_tween()
	tween1.tween_property(pointLight, "energy", 3, 20)
	
	var tween2 = get_tree().create_tween()
	tween2.tween_property(pointLight2, "energy", 3, 20)
	
	var tween3 = get_tree().create_tween()
	tween3.tween_property(pointLight3, "energy", 1.5, 20)
	
	
func day_state():
	pass

func night_state():
	pass

func _on_day_night_timeout():
	if state < 3:
		@warning_ignore("int_as_enum_without_cast")
		state += 1
	else:
		state = State.MORNING
