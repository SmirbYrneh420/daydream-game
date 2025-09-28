# HealthUI.gd - Attach to a Control node with heart sprites
extends Control

var hearts = []
var max_hearts = 4

func _ready():
	setup_hearts()

func setup_hearts():
	# Assuming you have heart sprites as children
	# Or create them programmatically
	for i in range(max_hearts):
		var heart = TextureRect.new()
		heart.texture = preload("res://frames/full_helth.png")  # Your heart texture
		heart.size = Vector2(32, 32)
		heart.position = Vector2(i * 40, 0)
		add_child(heart)
		hearts.append(heart)

func update_health(current_health: int, max_health_val: int):
	max_hearts = max_health_val
	
	for i in range(hearts.size()):
		if i < current_health:
			# Full heart
			hearts[i].modulate = Color.WHITE
			hearts[i].texture = preload("res://frames/full_helth.png")
		else:
			# Empty heart
			hearts[i].modulate = Color(0.3, 0.3, 0.3, 1.0)  # Grayed out
			hearts[i].texture = preload("res://frames/empty_helth.png")
