extends Node2D
@export var mob_scene: PackedScene

# Optional: path to this main scene file so we can reload on game over. If empty, we'll try to reload the current scene.
@export var main_scene_path: String = ""

# Called when the node enters the scene tree for the first time.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func new_game():
	pass

func game_over():
	# Let HUD show the game over UI, then reload the scene to reset state.
	$HUD.game_over()
	# give HUD a moment to show message (or await its timer). We'll wait one second then reload.
	await get_tree().create_timer(1.0).timeout

	var path = "res://main.tscn"
	if path == "":
		var cs = get_tree().get_current_scene()
		if cs and cs.filename != "":
			path = cs.filename
	if path != "":
		var err = get_tree().change_scene_to_file(path)
		if err != OK:
			push_error("Failed to reload scene: %s" % path)
	else:
		# fallback: try to restart the tree by reloading the project root scene
		get_tree().reload_current_scene()
	
func on_intro_conclude():
	var mob = mob_scene.instantiate()

func _on_hud_start_game() -> void:
	pass # Replace with function body.


func _on_area_2d_area_entered(area: Area2D) -> void:
	print("entered shortcut area.")
	$HUD.show_dialogue("To access this Shortcut, you must Sacrifice your Escort. Sacrifice your Escort?", ["Yes", "No"])
