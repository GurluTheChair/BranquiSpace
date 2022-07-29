extends Node2D

var spawn
var camera
var music

var charge = preload("res://Sons/Entities/Player/charge.wav")
var discharge = preload("res://Sons/Entities/Player/discharge.wav")
var focus = preload("res://Sons/Entities/Player/focus.wav")
var shockwave = preload("res://Sons/Entities/Player/shockwave.wav")

var better = false


func _ready():
	spawn = get_parent().get_parent().get_node("Spawned")
	camera = get_parent().get_parent().get_node("Camera")
	music = get_parent().get_parent().get_node("Music")
	
	var start = charge
	var end = discharge
	if better:
		start = focus
		end = shockwave
	
	$DoomSound.stream = start
	$DoomSound.play()
	yield(get_tree().create_timer(1), "timeout")
	get_tree().paused = false
	music.set_volume_db(-80)
	music.set_stream_paused(false)
	
	$Tween.interpolate_property(music, "volume_db", -80, -13, 2.0, Tween.TRANS_SINE, Tween.EASE_IN, 0)
	$Tween.start()
	
	for n in spawn.get_children():
		if ("Caillou" in n.name) or ("Enemy" in n.name) or ("Bullet_E" in n.name):
			n.kill(true)
	
	camera.shake(50)
	get_node("Charge").queue_free()
	get_node("Boom").emitting = true
	get_node("Boom/Trail").emitting = true
	$DoomSound.stream = end
	$DoomSound.play()

	yield(get_tree().create_timer(0.9), "timeout")
	get_node("Boom").emitting = false
	get_node("Boom/Trail").emitting = false
	yield(get_tree().create_timer(2), "timeout")
	
	queue_free()
