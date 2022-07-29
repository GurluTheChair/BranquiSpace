extends KinematicBody2D

export var h_speed = 100
export var v_speed = 50

var death = preload("res://Scenes/Effects/Explosion.tscn")
var shield_off = preload("res://Scenes/Effects/Boubou_Explosion.tscn")

var life = 1
var life_max = 2
var h_direction = 1

var velocity = Vector2()

func _ready():
	randomize()
	h_direction = randi()%3 - 1

func _physics_process(delta):
	position.x += h_speed * delta * h_direction
	position.y += v_speed * delta
	if position.x < 25 or position.x > 525:
		h_direction *= -1
	
func kill(anihilated):
	get_parent().get_parent().get_node("Camera").shake(1)
	var death_instance = death.instance()
	death_instance.position = position
	if(anihilated):
		var Player = get_parent().get_parent().get_node("Player")
		var direction = ( Player.position - death_instance.position ).normalized()
		death_instance.get_node("DeathSound").autoplay = false
		death_instance.get_node("Bullet").visible = false
		var gravity_x = direction.x * (-100000)
		var gravity_y = direction.y * (-100000)
		death_instance.get_node("Effect").set_gravity(Vector2(gravity_x,gravity_y))
	get_parent().get_parent().get_node("Spawned").call_deferred("add_child",death_instance)
	queue_free()
	
func shield_on():
	life += 1
	$Boubou/Pop.play("BouclierPop")
	$Boubou/BoubouP.emitting = true
	$Boubou/BoubouA.play()
	
func hurt():
	get_parent().get_parent().get_node("Camera").shake(1)
	if life >= life_max:
			$Boubou/Pop.play_backwards("BouclierPop")
			$Boubou/BoubouP.emitting = false
			var shield_off_instance = shield_off.instance()
			shield_off_instance.position = position
			get_parent().get_parent().get_node("Spawned").call_deferred("add_child",shield_off_instance)
	life -= 1
	

func _on_Area2D_body_entered(body):
	if "Bullet_P" in body.name:
		body.queue_free()
		hurt()
		if life < 1:
			kill(false)
	if "Gop" in body.name:
		if life < life_max:
			shield_on()
			body.queue_free()

