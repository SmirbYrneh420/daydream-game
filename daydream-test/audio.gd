extends Node

func play_sound(sound: String, volume_db:=0.0, pitch_scale:=1.0, max_polyphony:=1, bus:="Master"):
	var soundinstance = AudioStreamPlayer.new()
	add_child(soundinstance)
	soundinstance.stream = load(sound)
	soundinstance.bus = bus
	soundinstance.volume_db = volume_db
	soundinstance.pitch_scale = pitch_scale
	soundinstance.max_polyphony = max_polyphony

	soundinstance.play()
	await soundinstance.finished
	soundinstance.queue_free()
