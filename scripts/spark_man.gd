extends Node


@onready var layer_1: TileMapLayer = $layer1
@onready var layer_2: TileMapLayer = $layer2
@onready var flicker_timer: Timer = $FlickerTimer


var flicker_state = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	flicker_timer.wait_time = 0.075 # 6 frams at 60fps
	flicker_timer.timeout.connect(_on_flicker_timer_timeout)
	flicker_timer.start()
	
func _on_flicker_timer_timeout():
	flicker_state = !flicker_state
	layer_1.visible = flicker_state
	layer_2.visible = !flicker_state
	
	
