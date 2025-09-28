extends CharacterBody2D

var health = 4
const SPEED = 75.0
const JUMP_VELOCITY = -250.0

var is_invincible = false
var invincibility_duration = 1.0
var flash_duration = 0.1
var input_enabled = true

func _ready() -> void:
	# If there's a VisibleOnScreenNotifier2D (or similarly named node), connect its exit signal
	var notifier = find_child("VisibleOnScreenNotifier2D", true, false)
	if notifier:
		if notifier.has_signal("screen_exited"):
			notifier.screen_exited.connect(Callable(self, "_on_visible_on_screen_notifier_2d_screen_exited"))
	else:
		# create a notifier so we can detect when escort leaves the screen
		var vn = VisibleOnScreenNotifier2D.new()
		add_child(vn)
		# try to give it a small rect to match the escort collision area (optional)
		if has_node("CollisionShape2D"):
			# no direct API to size notifier here; leave default
			pass
		vn.screen_exited.connect(Callable(self, "_on_visible_on_screen_notifier_2d_screen_exited"))

func take_damage(amount: int = 1):
	if is_invincible:
		return  # Can't take damage while invincible
	
	health -= amount
	health = max(0, health)
	
	print("Escort took damage.")
	
	update_health_display()
	start_invincibility()
	
	if health <= 0:
		game_over()
	else:
		# Flash effect when taking damage
		flash_damage()

func start_invincibility():
	is_invincible = true
	await get_tree().create_timer(invincibility_duration).timeout
	is_invincible = false

func flash_damage():
	# Flash red when taking damage
	$AnimatedSprite2D.modulate = Color.RED
	await get_tree().create_timer(flash_duration).timeout
	$AnimatedSprite2D.modulate = Color.WHITE

func update_health_display():
	# Update UI health display (assuming you have heart sprites or health bar)
	$HealthUIEscort.update_health(health, 4)

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

func game_over():
	print("Escort died!")
	input_enabled = false
	# Add death animation or effects here
	$AnimatedSprite2D.stop()
	$AnimatedSprite2D.modulate = Color.GRAY
	$HUD.game_over()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	# When the escort leaves the camera view, trigger game over and free.
	var root_scene = get_tree().get_current_scene()
	if root_scene and root_scene.has_method("game_over"):
		root_scene.game_over()
	else:
		var hud = root_scene.find_node("HUD", true, false) if root_scene else null
		if hud and hud.has_method("game_over"):
			hud.game_over()
	queue_free()
