extends CanvasLayer

var restart_sound = preload("res://Sons/UI/restart.wav")
var gameover = preload("res://Sons/UI/gameover.wav")
var tragedy = preload("res://Sons/UI/tragedy.wav")

var spawn
var sfx

var better = false

func _ready():
	spawn = get_parent().get_parent().get_node("Spawned")
	sfx = get_parent().get_parent().get_node("SFX_Handler")
	if better:
		$GameOverSound.stream = tragedy
		$GameOverSound.set_pitch_scale(1.0)
		$GameOverSound.set_volume_db(0)
	else:
		$GameOverSound.stream = gameover
		$GameOverSound.set_pitch_scale(0.5)
		$GameOverSound.set_volume_db(-20)
	$GameOverSound.play()

func _on_Restart_pressed():
	for n in spawn.get_children():
		spawn.remove_child(n)
		n.queue_free()
# warning-ignore:return_value_discarded
	get_tree().reload_current_scene()
	sfx.stream = restart_sound
	get_tree().paused = false
	sfx.play()

func _on_Quit_pressed():
	get_tree().quit()
