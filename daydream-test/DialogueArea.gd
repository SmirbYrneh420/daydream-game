extends Area2D

# DialogueArea: configure prompt & options in the inspector
# - prompt: shown message
# - options: Array of Strings shown as choices
# - despawn_on_choice: index or -1 for none. If set to an index number, choosing that option will despawn the escort node.

@export var prompt: String = "Talk"
@export var options: Array = ["Hello", "Goodbye"]
# If >=0, will despawn escort when that option index is chosen
@export var despawn_on_choice := -1

var _player_inside := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") or body.name.to_lower().find("player") != -1:
		_player_inside = true
		# Request HUD to show the dialogue
		# Find the HUD in the current scene tree (robust search)
		var root_scene = get_tree().get_current_scene()
		var hud = null
		if root_scene:
			hud = root_scene.find_node("HUD", true, false)
		if not hud:
			# last resort: search entire tree
			hud = get_tree().get_root().find_node("HUD", true, false)
		if hud and hud.has_method("show_dialogue"):
			# show_dialogue expects a Callable that will be called with the index
			hud.show_dialogue(prompt, options, Callable(self, "_on_player_choice"))

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player") or body.name.to_lower().find("player") != -1:
		_player_inside = false

func _on_player_choice(index: int) -> void:
	# Handle the chosen option. If it matches despawn_on_choice, despawn the escort.
	if despawn_on_choice >= 0 and index == int(despawn_on_choice):
		# Try to find the escort node and remove it
		var escort = get_node_or_null("/root/Node2D/escort")
		if not escort:
			escort = get_node_or_null("../escort")
		if escort:
			escort.queue_free()
*** End Patch