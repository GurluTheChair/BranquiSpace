extends RigidBody2D

var death = preload("res://Scenes/Effects/Explosion.tscn")
var parade = preload("res://Scenes/Effects/Parade.tscn")

var spawn
var camera

func _ready():
	spawn = get_parent().get_parent().get_node("Spawned")
	camera = get_parent().get_parent().get_node("Camera")

func kill(anihilated):
	var death_instance
	
	if(anihilated):
		camera.shake(1)
		death_instance = death.instance()
		death_instance.modulate = Color8(255,127,0)
		death_instance.get_node("Effect").amount = 5
		var Player = get_parent().get_parent().get_node("Player")
		var direction = ( Player.position - death_instance.position ).normalized()
		death_instance.get_node("DeathSound").autoplay = false
		var gravity_x = direction.x * (-100000)
		var gravity_y = direction.y * (-100000)
		death_instance.get_node("Effect").gravity = Vector2(gravity_x,gravity_y)
	else:
		camera.shake(2)
		death_instance = parade.instance()
	
	death_instance.position = position
	spawn.call_deferred("add_child",death_instance)
	queue_free()


func _on_Area2D_body_entered(body):
	if "Bullet_P" in body.name: 
		body.queue_free()
		kill(false)
