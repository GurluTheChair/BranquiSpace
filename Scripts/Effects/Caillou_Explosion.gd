extends Node2D

func _ready():
	get_node("Effect").emitting = true
	get_node("Effect2").emitting = true
	yield(get_tree().create_timer(0.95), "timeout")
	get_node("Effect").emitting = false
	get_node("Effect2").emitting = false
	yield(get_tree().create_timer(1), "timeout")
	queue_free()
