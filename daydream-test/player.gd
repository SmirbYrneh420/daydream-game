extends CharacterBody2D

var health = 4
const SPEED = 75.0
const JUMP_VELOCITY = -250.0

# Shooting system
const BULLET_SCENE = preload("res://Bullet.tscn")
@export var fire_rate = 0.3  # Time between shots
var can_shoot = true
var input_enabled = true

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if input_enabled:
		handle_player_input()
	else:
		# When input disabled, stop horizontal movement and animations
		velocity.x = move_toward(velocity.x, 0, SPEED)
		$AnimatedSprite2D.stop()
	
	# Move and slide should always be called
	move_and_slide()

func handle_player_input():
	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Handle movement
	var direction := Input.get_axis("left", "right")
	if direction:
		$AnimatedSprite2D.flip_h = velocity.x > 0
		$AnimatedSprite2D.play()
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		$AnimatedSprite2D.stop()
	
	# Handle shooting
	if Input.is_action_pressed("shoot") and can_shoot:
		shoot_at_mouse()

func set_input_enabled(enabled: bool):
	input_enabled = enabled
	
func shoot_at_mouse():
	can_shoot = false
	
	# Create bullet
	var bullet = BULLET_SCENE.instantiate()
	
	# Calculate direction from player to mouse FIRST
	var mouse_pos = get_global_mouse_position()
	var shoot_direction = (mouse_pos - global_position).normalized()
	
	# Position bullet with offset in the shooting direction (outside player collision)
	var bullet_offset = shoot_direction * 30  # 30 pixels away from player center
	bullet.global_position = global_position + bullet_offset
	
	# Set bullet direction
	bullet.set_direction(shoot_direction)
	
	# Add bullet to scene tree (not as child of player)
	get_tree().current_scene.add_child(bullet)
	
	# Start cooldown
	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true

func game_over():
	print("Player died!")
	input_enabled = false
	# Add death animation or effects here
	$AnimatedSprite2D.stop()
	$AnimatedSprite2D.modulate = Color.GRAY
	$HUD.game_over()
