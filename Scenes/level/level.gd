extends Node2D

@onready var light_animation = $Light/LightAnimation
@onready var day_text = $CanvasLayer/DayText
@onready var player = $Character/Player

var mashroom_preload = preload("res://Scenes/Mobs/Mashroom.tscn")

enum State {
	MORNING,
	DAY,
	EVENING,
	NIGHT
}

var state = State.MORNING
var day_count: int

func _ready():
	Global.gold = 0
	day_count = 0
	morning_state()
	
func morning_state():
	day_count += 1
	day_text.text = "DAY " + str(day_count)
	light_animation.play("sunrise")
	
func evening_state():
	light_animation.play("sunset")
	
func _on_day_night_timeout():
	if state < 3:
		state += 1
	else:
		state = 0
	match state:
		State.MORNING:
			morning_state()
		State.EVENING:
			evening_state()
			
	Signals.emit_signal("day_time",state)
			
		

func _on_spawner_timeout():
	mushroom_spawn()

func mushroom_spawn():
	var mushroom = mashroom_preload.instantiate() 
	mushroom.position = Vector2(randi_range(-500, -200), 480)
	$Mobs.add_child(mushroom)
