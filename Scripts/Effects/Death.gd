extends Node2D

var fade_animation = preload("res://Images/Animations/Fade_ZoneLine.tres")

var death = preload("res://Sons/Entities/Player/death.wav")
var final_hit = preload("res://Sons/Entities/Player/final_hit.wav")
var implosion = preload("res://Sons/Entities/Player/implosion.wav")
var explosion = preload("res://Sons/Entities/Player/explosion.wav")

var better = false

func _ready():
	var camera = get_parent().get_parent().get_node("Camera")
	var particles = get_parent().get_parent().get_node("Particles2D")
	var player = get_parent().get_parent().get_node("Player")
	
	var start = implosion
	var end = explosion
	if better:
		start = final_hit
		end = death
	
	get_parent().get_parent().get_node("Music").stop()
	$DoomSound.stream = start
	$DoomSound.play()
	yield(get_tree().create_timer(2.5), "timeout")
	get_tree().paused = false
	
	camera.shake(100)
	get_node("Trail").emitting = true
	$DoomSound.stream = end
	$DoomSound.play()
	player.get_node("Sprite").set_deferred("visible", false)
	particles.emitting = false
	player.get_node("Light2D").set_deferred("enabled", false)
	player.get_node("Zone/Zone Limit/Fade").play_backwards("Fade_ZoneLine")

	yield(get_tree().create_timer(0.9), "timeout")
	get_node("Trail").emitting = false
	yield(get_tree().create_timer(2), "timeout")
	
	queue_free()
