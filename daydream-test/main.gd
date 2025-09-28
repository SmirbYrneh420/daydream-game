extends Node2D
@export var mob_scene: PackedScene

# Called when the node enters the scene tree for the first time.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func new_game():
	pass

func game_over():
	$HUD.show_game_over()
	
func on_intro_conclude():
	var mob = mob_scene.instantiate()
	


func _on_hud_start_game() -> void:
	pass # Replace with function body.
