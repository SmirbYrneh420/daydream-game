extends CharacterBody2D
const SPEED = 50.0
const JUMP_VELOCITY = -250.0

var direction = 1 # let's just make it easier to operate on.
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if (randf() > 0.5):
		direction = -1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	velocity.x = SPEED * direction
	
	var was_moving = (velocity.x != 0)
	move_and_slide()
	
	if (was_moving and velocity.x == 0):
		direction *= -1
	
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
