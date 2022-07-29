extends Node2D

func _ready():
	get_node("TopLeft").emitting = true
	get_node("TopRight").emitting = true
	get_node("BottomLeft").emitting = true
	get_node("BottomRight").emitting = true
	get_node("Explosion").emitting = true
	
	yield(get_tree().create_timer(0.3), "timeout")
	
	get_node("Explosion").emitting = false
	
	yield(get_tree().create_timer(0.1), "timeout")
	
	get_node("TopLeft").emitting = false
	get_node("TopRight").emitting = false
	get_node("BottomLeft").emitting = false
	get_node("BottomRight").emitting = false
	
	yield(get_tree().create_timer(3), "timeout")
	queue_free()
