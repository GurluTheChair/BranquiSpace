extends Node2D

func _ready():
	var spray = get_node("Right").direction
	get_node("Left").direction = Vector2(-spray.x, -spray.y)
	
	
	get_node("Right").emitting = true
	get_node("Left").emitting = true
	get_node("Explosion").emitting = true
	yield(get_tree().create_timer(0.1), "timeout")
	get_node("Explosion").emitting = false
	yield(get_tree().create_timer(0.1), "timeout")
	get_node("Right").emitting = false
	get_node("Left").emitting = false
	yield(get_tree().create_timer(1), "timeout")
	queue_free()
