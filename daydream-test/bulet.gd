extends CharacterBody2D

@export var speed = 500.0
var direction = Vector2.ZERO

func _ready():
	print("Bullet created with set_direction method")  # Debug line
	
	# Auto-destroy after 3 seconds
	var timer = Timer.new()
	timer.wait_time = 3.0
	timer.one_shot = true
	timer.timeout.connect(queue_free)
	add_child(timer)
	timer.start()
	$AudioStreamPlayer2D.play()

func _physics_process(delta):
	# Set velocity and move
	velocity = direction * speed
	move_and_slide()
	
	# Check for collisions after moving
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider:
			print("Bullet hit: ", collider.name)  # Debug line
			# Don't hit the player who shot the bullet
			if collider.name != "Player":
				# Hit something else - destroy bullet
				if collider.has_method("take_damage"):
					collider.take_damage(1)
				queue_free()
				return

func set_direction(new_direction: Vector2):
	print("set_direction called with: ", new_direction)  # Debug line
	direction = new_direction.normalized()
	rotation = direction.angle()
