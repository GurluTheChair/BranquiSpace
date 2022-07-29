extends CPUParticles2D

func _ready():
	emitting = true
	yield(get_tree().create_timer(0.1), "timeout")
	emitting = false
	yield(get_tree().create_timer(3), "timeout")
	queue_free()
