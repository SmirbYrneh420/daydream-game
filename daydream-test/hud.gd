extends CanvasLayer

signal start_game

func show_message(msg):
	$Title.text = msg
	$Title.show()
	$MessageTimer.start()

func game_over():
	show_message("GAME OVER")
	await $MessageTimer.timeout
	
	disable_player_input()
	$Title.text = "Testing Testing 123"
	$Title.show()
	$Polygon2D.show()
	$StartButton.show()
	
func _on_start_button_pressed():
	$StartButton.hide()
	$Polygon2D.hide()
	show_message("Escape!")
	enable_player_input()
	start_game.emit()
	Audio.play_sound("res://frames/floppy_countdown.mp3")

func _on_message_timer_timeout():
	$Title.hide()
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func disable_player_input():
	# Disable input processing for all players
	var player = get_node("../Player")  # Adjust path to your player node
	if player:
		player.set_input_enabled(false)

func enable_player_input():
	# Enable input processing for all players
	var player = get_node("../Player")  # Adjust path to your player node
	if player:
		player.set_input_enabled(true)


# -------------------- Dialogue helpers --------------------
# Show a prompt with multiple options. `options` is an Array of Strings.
# `response_callback` is a Callable that will be called as: response_callback.call(index, option_string)
func show_dialogue(prompt: String, options: Array, response_callback: Callable) -> void:
	# Disable player input while dialogue is active
	disable_player_input()
	# basic panel created at runtime and parented to HUD
	var panel := PanelContainer.new()
	panel.name = "RuntimeDialogue"
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.5
	panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	panel.rect_min_size = Vector2(300, 120)
	# PanelContainer doesn't expose horizontal_alignment; sizing is handled by containers.

	var vbox := VBoxContainer.new()
	vbox.margin_top = 8
	vbox.margin_left = 8
	vbox.margin_right = 8
	vbox.margin_bottom = 8
	panel.add_child(vbox)

	var label := Label.new()
	label.text = prompt
	label.percent_visible = 1.0
	label.wrap = true
	vbox.add_child(label)

	var btn_box := HBoxContainer.new()
	btn_box.custom_minimum_size = Vector2(0, 36)
	vbox.add_child(btn_box)

	# create buttons for options
	for i in range(options.size()):
		var b := Button.new()
		b.text = str(options[i])
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		# connect with bound args: index and the response callback
		b.pressed.connect(_on_runtime_dialog_choice, i)
		btn_box.add_child(b)

	add_child(panel)

func _on_runtime_dialog_choice(index: int, response_callback: Callable) -> void:
	# Clean up the runtime panel
	var panel = get_node_or_null("RuntimeDialogue")
	if panel:
		panel.queue_free()
	# Re-enable player input
	enable_player_input()
	# call the response callback
	if response_callback and response_callback.is_valid():
		response_callback.call(index)
