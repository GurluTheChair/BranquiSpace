extends Node2D

func _ready():
	get_node("Effect").emitting = true
	get_node("Bullet").emitting = true
	yield(get_tree().create_timer(0.20), "timeout")
	get_node("Bullet").emitting = false
	yield(get_tree().create_timer(0.35), "timeout")
	get_node("Effect").emitting = false
	yield(get_tree().create_timer(1), "timeout")
	queue_free()
