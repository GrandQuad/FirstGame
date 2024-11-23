extends Node2D

@onready var light = $Light/Sun
@onready var day_text = $CanvasLayer/DayText
@onready var player = $Character/Player

var mashroom_preload = preload("res://Scenes/Mobs/Mashroom.tscn")

enum State {
	MORNING,
	EVENING,
	DAY,
	NIGHT
}

var state = State.MORNING
var day_count: int

func _ready():
	Global.gold = 0
	day_count = 1
	morning_state()
	

func morning_state():
	day_count += 1
	day_text.text = "DAY " + str(day_count)
	light.play("sunrise")
	
	

func evening_state():
	var tween = get_tree().create_tween()
	tween.tween_property(light, "energy", 0.95, 20)
	
	
	
func _on_day_night_timeout():
	match state:
		State.MORNING:
			morning_state()
		State.EVENING:
			evening_state()
			
	if state < 3:
		@warning_ignore("int_as_enum_without_cast")
		state += 1
	else:
		state = State.MORNING
		day_count += 1
		



func _on_spawner_timeout():
	mushroom_spawn()

func mushroom_spawn():
	var mushroom = mashroom_preload.instantiate() 
	mushroom.position = Vector2(randi_range(-500, -200), 480)
	$Mobs.add_child(mushroom)
