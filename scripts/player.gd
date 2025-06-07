extends CharacterBody2D


const SPEED = 70.0
const JUMP_VELOCITY = -275.0
const CLIMB_SPEED = 60

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var on_ladder = false
var can_grab_ladder = false
var ladder_area : Area2D = null

func _ready() -> void:
	for ladder in get_tree().get_nodes_in_group("ladder"):
		ladder.connect("body_entered", Callable(self, "_on_ladder_body_entered").bind(ladder))
		ladder.connect("body_exited", Callable(self, "_on_ladder_body_exited").bind(ladder))


func _physics_process(delta: float) -> void:
	var up := Input.is_action_pressed("move_up")
	var down := Input.is_action_pressed("move_down")
	
	# Ladder: Enter logic
	if not on_ladder and can_grab_ladder and up:
		enter_ladder()
	
	# Ladder climbing behavior
	if on_ladder:
		# Climbing movement
		if up:
			velocity.y = -CLIMB_SPEED
		elif down:
			velocity.y = CLIMB_SPEED
		else:
			velocity.y = 0
			
		# Exit ladder if jump is pressed
		if Input.is_action_just_pressed("jump"):
			exit_ladder()
			velocity.y = -JUMP_VELOCITY
			
		
	elif is_on_floor() and down and not on_ladder and can_grab_ladder and ladder_area:
		print("Entering ladder from top")
		global_position.y += 5
		enter_ladder()
	else:
		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta

		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("walk_left", "walk_right")
	
	# Flip the sprite if needed
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
		
	# Play animation
	if on_ladder:
		if up or down:
			animated_sprite.play("climb")
		else:
			animated_sprite.pause()
		
	elif is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("walk")
	else:
		animated_sprite.play("jump")
	
	# Apply Movment
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	if global_position.y >= 120 :
		get_tree().reload_current_scene()

	move_and_slide()




func exit_ladder():
	on_ladder = false
	
func enter_ladder():
	on_ladder = true
	velocity = Vector2.ZERO
	if ladder_area:
		global_position.x = ladder_area.global_position.x


func _on_ladder_body_entered(body: Node2D, ladder: Area2D) -> void:
	if body == self:
		print("Entered ladder area")
		can_grab_ladder = true
		ladder_area = ladder


func _on_ladder_body_exited(body: Node2D, ladder: Area2D) -> void:
	if body == self and ladder_area == ladder:
		can_grab_ladder = false
		if on_ladder:
			exit_ladder()
		ladder_area = null
		print("Exited ladder")
