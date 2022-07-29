extends KinematicBody2D

export var h_speed = 300
export var v_speed = 50
export var camping = 125
export var bullet_speed = 400

var death = preload("res://Scenes/Effects/Explosion.tscn")
var shield_off = preload("res://Scenes/Effects/Boubou_Explosion.tscn")
var bullet = preload("res://Scenes/Entities/Bullet_E.tscn")

var life = 1
var life_max = 2

var spawn
var player
var camera
var velocity = Vector2()

func _ready():
	spawn = get_parent().get_parent().get_node("Spawned")
	player = get_parent().get_parent().get_node("Player")
	camera = get_parent().get_parent().get_node("Camera")

func _physics_process(_delta):
	position.y += (camping - position.y)/v_speed
	position.x += (player.position.x - position.x)/h_speed
	
	var _err = move_and_collide(velocity)

func shoot():
	var bullet_instance = bullet.instance()
	bullet_instance.position = position
	bullet_instance.modulate = Color8(255,127,0)
	bullet_instance.apply_impulse(Vector2(), Vector2(0,bullet_speed).rotated(rotation))
	spawn.call_deferred("add_child",bullet_instance)
	
func kill(anihilated):
	camera.shake(1)
	var death_instance = death.instance()
	death_instance.get_node("Effect").modulate = Color8(255,127,0)
	death_instance.position = position
	if(anihilated):
		var direction = ( player.position - death_instance.position ).normalized()
		death_instance.get_node("DeathSound").autoplay = false
		death_instance.get_node("Bullet").visible = false
		var gravity_x = direction.x * (-100000)
		var gravity_y = direction.y * (-100000)
		death_instance.get_node("Effect").gravity = Vector2(gravity_x,gravity_y)
	spawn.call_deferred("add_child",death_instance)
	queue_free()
	
func shield_on():
	life += 1
	$Boubou/Pop.play("BouclierPop")
	$Boubou/BoubouP.emitting = true
	$Boubou/BoubouA.play()
	
func hurt():
	camera.shake(1)
	if life >= life_max:
			$Boubou/BoubouP.emitting = false
			$Boubou/Pop.play_backwards("BouclierPop")
			var shield_off_instance = shield_off.instance()
			shield_off_instance.position = position
			spawn.call_deferred("add_child",shield_off_instance)
	life -= 1
	

func _on_Area2D_body_entered(body):
	if ("Bullet_P" in body.name):
		body.queue_free()
		hurt()
		if life < 1:
			kill(false)
	if "Gop" in body.name:
		if life < life_max:
			shield_on()
			body.queue_free()


func _on_Fire_Timer_timeout():
	shoot()
