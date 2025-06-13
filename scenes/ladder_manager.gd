extends Node

signal ladder_transition_started
signal ladder_transition_completed

const TRANSITION_DURATION = 1.5
const COOLDOWN_DURATION = 1.0

@onready var player: CharacterBody2D = $"../Player"
@onready var camera: Camera2D = $"../Camera2D"
@onready var screen1_entry: Area2D = $"../Screen1_LadderEntry"
@onready var screen2_entry: Area2D = $"../Screen2_LadderEntry"


var is_transitioning := false
var transition_cooldown_until := 0.0

func _ready() -> void:
	await get_tree().process_frame
	initialize_connections()
	
func initialize_connections() -> void:
	for exit in get_tree().get_nodes_in_group("ladder_exits"):
		exit.connect("body_entered", Callable(self, "_on_ladder_exit_entered").bind(exit))
		
	for ladder in get_tree().get_nodes_in_group("ladder_entries"):
		ladder.connect("body_entered", Callable(self, "_on_ladder_entry_entered").bind(ladder))
		ladder.connect("body_exited", Callable(self, "_on_ladder_entry_exited").bind(ladder))

	for ladder in get_tree().get_nodes_in_group("ladder"):
		ladder.connect("body_entered", Callable(self, "_on_ladder_entry_entered").bind(ladder))
		ladder.connect("body_exited", Callable(self, "_on_ladder_entry_exited").bind(ladder))
		
func _on_ladder_entry_entered(body: Node2D, entry: Area2D) -> void:
	if body != player:
		return
		
	player.ladder_area = entry
	player.can_grab_ladder = true
	
func _on_ladder_entry_exited(body: Node2D, entry: Area2D) -> void:
	if body == player and player.ladder_area == entry:
		player.can_grab_ladder = false
		if player.on_ladder:
			player.exit_ladder()
		player.ladder_area = null
		
func _on_ladder_exit_entered(body: Node2D, exit: Area2D) -> void:
	if body != player or is_transitioning:
		return
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time < transition_cooldown_until:
		return

	if player.on_ladder:
		if exit.is_in_group("up_transition_points"):
			start_ladder_transition(exit, Vector2(0, -273), false)
		elif exit.is_in_group("down_transition_points"):
			start_ladder_transition(exit, Vector2(0, 273), true)

	
func start_ladder_transition(exit: Area2D, offset: Vector2, going_down: bool) -> void:
	is_transitioning = true
	player.is_transitioning = true
	player.visible = false
	emit_signal("ladder_transition_started")
	
	var target_pos = camera.global_position + offset
	
	var tween = get_tree().create_tween()
	tween.tween_property(camera, "global_position", target_pos, TRANSITION_DURATION) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	# When going downward, we need a different target position
	var target_entry = screen1_entry if going_down else screen2_entry

	tween.tween_callback(Callable(self, "_on_ladder_transition_complete").bind(target_entry, going_down))
	
func _on_ladder_transition_complete(target_entry: Area2D, going_down: bool) -> void:
	player.global_position = target_entry.global_position
	if going_down:
		player.global_position.y += 16
	else:
		player.global_position.y -= 32

	player.velocity = Vector2.ZERO
	player.on_ladder = true
	player.is_transitioning = false
	player.visible = true
	
	is_transitioning = false
	transition_cooldown_until = Time.get_ticks_msec() / 1000.0 + COOLDOWN_DURATION
	emit_signal("ladder_transition_completed")
	
	
		
