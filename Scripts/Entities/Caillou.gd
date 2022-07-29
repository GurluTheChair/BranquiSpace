extends RigidBody2D

var death = preload("res://Scenes/Effects/Caillou_Explosion.tscn")

func kill(anihilated, isP = true):
	var death_instance = death.instance()
	death_instance.position = position
	get_parent().get_parent().get_node("Camera").shake(1.5)
	if(isP):
		death_instance.get_node("BulletP").emitting = true
	else:
		death_instance.get_node("BulletE").emitting = true
	if(anihilated):
		death_instance.get_node("BulletP").emitting = false
		var Player = get_parent().get_parent().get_node("Player")
		var direction = ( Player.position - death_instance.position ).normalized()
		var gravity_x = direction.x * (-100000)
		var gravity_y = direction.y * (-100000)
		death_instance.get_node("DeathSound").autoplay = false
		death_instance.get_node("BulletP").set_visible(false)
		death_instance.get_node("BulletE").set_visible(false)
		death_instance.get_node("Effect").gravity = Vector2(gravity_x,gravity_y)
		death_instance.get_node("Effect2").gravity = Vector2(gravity_x,gravity_y)
	get_parent().get_parent().get_node("Spawned").call_deferred("add_child",death_instance)
	queue_free()

func _on_Area2D_body_entered(body):
	if "Bullet" in body.name:
		body.queue_free()
		if "Bullet_P" in body.name:
			kill(false)
		else:
			kill(false, false)
