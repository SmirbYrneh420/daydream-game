extends Area2D

# Simple configurable spawner for Godot 4 (GDScript)
# Usage:
# - Add an Area2D node in the scene, attach this script.
# - Add a CollisionShape2D to define the spawn zone.
# - Set `spawn_scene` to your enemy PackedScene (e.g., preload("res://enemy_a.tscn")).
# - Optionally add child Marker2D nodes as specific spawn points (Position2D was removed in Godot 4). If none, spawns at random points inside the Area2D's shape.
# - Configure `spawn_interval`, `max_active` and `spawn_on_enter`.

@export var spawn_scene: PackedScene
@export var spawn_interval := 2.0 # seconds between spawns while player is inside
@export var max_active := 6 # maximum spawned alive at once
@export var spawn_on_enter := true # spawn immediately when player enters
@export var use_spawn_points := true # look for child Marker2D nodes to spawn at

var _active_enemies := []
var _spawn_timer := 0.0
var _player_inside := false

func _ready() -> void:
	# Connect body entered/exited to detect player (or other bodies)
	self.body_entered.connect(_on_body_entered)
	self.body_exited.connect(_on_body_exited)

func _process(delta: float) -> void:
	# Clean up freed enemies
	_active_enemies = _active_enemies.filter(func(e): return e and is_instance_valid(e))
	if _player_inside:
		_spawn_timer -= delta
		if _spawn_timer <= 0.0:
			_spawn_timer = spawn_interval
			if _active_enemies.size() < max_active:
				_spawn_enemy()

func _on_body_entered(body: Node) -> void:
	# Basic detection: treat the player as anything with group "player" or class name "Player"
	if body.is_in_group("player") or body.name.to_lower().find("player") != -1:
		_player_inside = true
		_spawn_timer = 0.0 if spawn_on_enter else spawn_interval

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player") or body.name.to_lower().find("player") != -1:
		_player_inside = false

func _spawn_enemy() -> void:
	if not spawn_scene:
		print("Spawner: spawn_scene not configured")
		return
	var enemy = spawn_scene.instantiate()
	# choose spawn position
	var spawn_pos = _choose_spawn_position()
	if enemy is Node2D:
		enemy.position = spawn_pos
	else:
		# fallback: set a transform if available
		if enemy.has_method("set_global_position"):
			enemy.call("set_global_position", spawn_pos)
	get_parent().add_child(enemy)
	_active_enemies.append(enemy)
	# Optionally connect to enemy's "tree_exited" or custom death signal to remove from active list
	if enemy.has_method("connect"):
		# try to cleanup when freed
		enemy.connect("tree_exited", Callable(self, "_on_enemy_tree_exited"))

func _on_enemy_tree_exited(node: Node) -> void:
	_active_enemies = _active_enemies.filter(func(e): return e != node)

func _choose_spawn_position() -> Vector2:
	# If child Marker2D nodes exist and use_spawn_points is true, choose among them
	var points := []
	if use_spawn_points:
		for c in get_children():
			# Marker2D is the Godot 4 replacement for Position2D. Also accept Node2D for compatibility.
			if c is Marker2D or c is Node2D:
				points.append(c.global_position)
	if points.size() > 0:
		return points[randi() % points.size()]
	# Otherwise, attempt to pick a random point inside the CollisionShape2D bounds
	for c in get_children():
		if c is CollisionShape2D and c.shape:
			# try RectangleShape2D or Circle/Convex; fallback to area global position
			var area_pos = global_position
			match c.shape:
				RectangleShape2D:
					var sz = c.shape.size
					var x = randf_range(-sz.x/2, sz.x/2)
					var y = randf_range(-sz.y/2, sz.y/2)
					return area_pos + Vector2(x, y)
				CircleShape2D:
					var r = c.shape.radius
					var angle = randf() * TAU
					var rad = randf() * r
					return area_pos + Vector2(cos(angle), sin(angle)) * rad
	# default to spawner position
	return global_position
