extends Node2D

export var gop_speed = 150

var gop = preload("res://Scenes/Entities/Gop.tscn")
var enemy = preload("res://Scenes/Entities/Enemy.tscn")
var enemy_s = preload("res://Scenes/Entities/Enemy_Shoot.tscn")

var enemy_s_frequency = 5
var count = enemy_s_frequency

func _ready():
	randomize()


func _on_Despawn_Walls_body_entered(body):
	body.queue_free()
	#print(body.name)


func _on_EnemySpawn_timeout():
	var enemy_instance
	if count == 0:
		enemy_instance = enemy_s.instance()
		count = enemy_s_frequency
	else:
		enemy_instance = enemy.instance()
		count -= 1
	enemy_instance.position = Vector2(rand_range(25, 500), rand_range(-100, -250))
	get_node("Spawned").call_deferred("add_child",enemy_instance)


func _on_GopSpawn_timeout():
	var gop_instance = gop.instance()
	gop_instance.position = Vector2(rand_range(10, 540),725)
	gop_instance.apply_impulse(Vector2(), Vector2(0,-gop_speed))
	get_node("Spawned").call_deferred("add_child",gop_instance)
