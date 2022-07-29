extends KinematicBody2D

export var bullet_speed = 500
export var caillou_speed = 50
export var life_max = 8
export var life_min = 0
export var transitionNumber=2.0
export var transitionDuration=0.3
export var gop_speed=200

var bullet = preload("res://Scenes/Entities/Bullet_P.tscn")
var caillou = preload("res://Scenes/Entities/Caillou.tscn")
var gameover = preload("res://Scenes/Menus/GameOverScreen.tscn")
var shockwave = preload("res://Scenes/Effects/Shockwave.tscn")
var Hurt = preload("res://Scenes/Effects/Hurt.tscn")
var death = preload("res://Scenes/Effects/Death.tscn")

var heal_sound = preload("res://Sons/Entities/Player/heal.wav")
var hurt_sound = preload("res://Sons/Entities/Player/player_impact.wav")
var hurt_2_sound = preload("res://Sons/Entities/Player/player_impact_2.wav")
var nope_sound = preload("res://Sons/Entities/Player/nope.wav")

var velocity = Vector2()
var life
var spawn
var camera
var moveable = true

func _ready():
	life = life_max-2
	update_lifebar()
	spawn = get_parent().get_node("Spawned")
	camera = get_parent().get_node("Camera")
	yield(get_tree().create_timer(1.5), "timeout")
	get_parent().get_node("Particles2D").emitting = true
	
func _process(_delta):
	match life:
		1:
			if $Sprite/MegaDanger.is_playing():
				$Sprite/MegaDanger.stop()
				$Sprite/MegaDanger.seek(0.0, true)
			if !$Sprite/Danger.is_playing():
				$Sprite/Danger.play("Danger")
		0: 
			if $Sprite/Danger.is_playing():
				$Sprite/Danger.stop()
				$Sprite/Danger.seek(0.0, true)
			if !$Sprite/MegaDanger.is_playing():
				$Sprite/MegaDanger.play("MegaDanger")
		life_max:
			if !$Sprite/Surcharge.is_playing():
				$Sprite/Surcharge.play("Surcharge")
				$Sprite/SurchargeP.emitting = true
		_:
			if $Sprite/Danger.is_playing():
				$Sprite/Danger.stop()
				$Sprite/Danger.seek(0.0, true)
			if $Sprite/Surcharge.is_playing():
				$Sprite/Surcharge.stop()
				$Sprite/Surcharge.seek(0.0, true)
				$Sprite/SurchargeP.emitting = false

func _physics_process(_delta):

	velocity = Vector2()
	if Input.is_action_pressed("right"):
		velocity.x += 1
	if Input.is_action_pressed("left"):
		velocity.x -= 1
	if Input.is_action_pressed("down"):
		velocity.y += 1
	if Input.is_action_pressed("up"):
		velocity.y -= 1
	var speed = process_speed(velocity.y)
	velocity = velocity.normalized() * speed
	velocity = move_and_slide(velocity)
	if Input.is_action_just_pressed("shoot"):
		if life > life_min:
			life -= 1
			update_lifebar()
			shoot()
		else:
			$PlayerSFX.stream = nope_sound
			$PlayerSFX.play()
	if Input.is_action_pressed("laser"):
		if life == life_max:
			if Input.is_action_pressed("shoot"):
				shoot(true)

func process_speed(direction):
	
	if(!moveable):
		return 0
	
	var wall_up = get_parent().get_node("Walls/Up")
	var wall_down = get_parent().get_node("Walls/Down")
	var up_distance = position.y - wall_up.position.y
	var down_distance = wall_down.position.y - position.y
	
	var speed_up = 200
	if up_distance < 125:
		speed_up = (up_distance-25) *2
	if up_distance > 225:
		speed_up = (up_distance-25)
		
	var speed_down = 200
	if down_distance < 125:
		speed_down = (down_distance-25) *2
	if down_distance > 225:
		speed_down = (down_distance-25)
	
	if direction > 0:
		return speed_down
	if direction < 0:
		return speed_up
	return 200

func shoot(silent = false):
	camera.shake(1)
	var bullet_instance = bullet.instance()
	bullet_instance.position = get_global_position()
	bullet_instance.rotation_degrees = rotation_degrees
	bullet_instance.apply_impulse(Vector2(), Vector2(0,-bullet_speed).rotated(rotation))
	if silent:
		bullet_instance.get_node("ShootSound").set_volume_db(-80)
	spawn.call_deferred("add_child",bullet_instance)
	
func ultimate(better = false):
	
	$MorphSFX.stop()
	$HurtSFX.stop()
	$PlayerSFX.stop()
	get_parent().get_node("Music").set_stream_paused(true)
	
	get_tree().paused = true
	var shockwave_instance = shockwave.instance()
	shockwave_instance.position = get_global_position()
	var transformed_position = (get_global_transform_with_canvas().origin/ get_viewport_rect().size)
	var aspect_ratio = get_viewport_rect().size.aspect()
	transformed_position.x = (transformed_position.x - 0.5) * aspect_ratio + 0.5
	shockwave_instance.get_node("CanvasLayer/ColorRect").material.set_shader_param("center", Vector2(transformed_position.x,1.0-transformed_position.y))
	if better:
		shockwave_instance.set("better", true)
	spawn.call_deferred("add_child",shockwave_instance)
	
	life = 2
	update_lifebar()

func kill(better = false):
	moveable = false
	get_node("Area2D/CollisionShape2D").set_deferred("disabled", true)
	get_node("CollisionShape2D").set_deferred("disabled", true)
	get_node("GopMorpher/CollisionShape2D").set_deferred("disabled", true)
	get_node("Zone/CreateLeft").emitting = false
	get_node("Zone/CreateRight").emitting = false
	get_node("Trail").emitting = false
	get_node("Trail2").emitting = false
	get_tree().paused = true
	var death_instance = death.instance()
	death_instance.position = get_global_position()
	var transformed_position = (get_global_transform_with_canvas().origin/ get_viewport_rect().size)
	var aspect_ratio = get_viewport_rect().size.aspect()
	transformed_position.x = (transformed_position.x - 0.5) * aspect_ratio + 0.5
	death_instance.get_node("CanvasLayer/ColorRect").material.set_shader_param("center", Vector2(transformed_position.x,1.0-transformed_position.y))
	if better:
		death_instance.set("better", true)
	spawn.call_deferred("add_child",death_instance)
	
	yield(get_tree().create_timer(4.3), "timeout")
	var gameover_instance = gameover.instance()
	if better:
		gameover_instance.set("better", true)
	add_child(gameover_instance)
	get_tree().paused = true
	

func _on_Area2D_body_entered(body):
	if "Gop"     in body.name: heal(body)
	if "Enemy"   in body.name: hurt(body, 2)
	if "Caillou" 	  in body.name: hurt(body, 1)
	if "Bullet_E" in body.name: hurt(body, 1)

func fade_out(stream_player):
	get_node("MorphSFX/Tween").interpolate_property(stream_player, "volume_db", -10, -80, 0.5, 1, Tween.EASE_IN, 0)
	get_node("MorphSFX/Tween").start()

func gopMorph(body):
	$MorphSFX.stop()
	$MorphSFX.volume_db = -10
	$MorphSFX.play()
	var color1=Color8(50,50,50)
	var color2=Color8(100,100,100)
	var i=1.0
	while i<=transitionNumber:
		var time=transitionDuration/i
		var factor=i/transitionNumber
		if is_instance_valid(body):
			body.modulate = color1
			yield(get_tree().create_timer(time), "timeout")
		else:
			fade_out($MorphSFX)
			
		if is_instance_valid(body):
			body.modulate = color2
			yield(get_tree().create_timer(transitionDuration-time), "timeout")
			#body.velocity=Vector2(0,(body.velocity.y+caillou_speed/2))
			if is_instance_valid(body):
				var newSpeed=-(gop_speed*(1.0-factor)+caillou_speed*factor)
				var lv = body.get_linear_velocity()
				lv=Vector2(0,newSpeed)
				body.set_linear_velocity(lv)
			else:
				fade_out($MorphSFX)
		else:
			fade_out($MorphSFX)
		i+=1.0
	if is_instance_valid(body):
		var caillou_instance = caillou.instance()
		caillou_instance.position = body.position
		caillou_instance.rotation_degrees = body.rotation_degrees
		caillou_instance.apply_impulse(Vector2(), Vector2(0,-caillou_speed))
		caillou_instance.add_torque(100.0)
		body.queue_free()
		spawn.call_deferred("add_child",caillou_instance)
	else:
		fade_out($MorphSFX)
		
func _on_GopMorpher_body_entered(body):
	if "Gop" in body.name:
		gopMorph(body)

func heal(body):
	if life < life_max:
		life += 1
		update_lifebar()
		$PlayerSFX.stream = heal_sound
		$PlayerSFX.play()
		$Sprite/Heal.play("Heal")
		$Sprite/HealP.emitting = true
	else:
		if Input.is_action_pressed("Better"):
			ultimate(true)
		else:
			ultimate()
	body.queue_free()

func hurt(body, damage):
	life -= damage
	if life < life_min:
		life = 0
		update_lifebar()
		body.queue_free()
		if Input.is_action_pressed("Better"):
			kill(true)
		else:
			kill()
	else:
		update_lifebar()
		camera.shake(10*damage)
		$Sprite/Hurt.play("Hurt")
		if damage <= 1:
			$HurtSFX.stream = hurt_sound
		else: 
			$HurtSFX.stream = hurt_2_sound
		$HurtSFX.play()
		
		var hurt_instance = Hurt.instance()
		var in_between = (body.position - position ) / 2
		var middle = body.position - in_between
		var spray = Vector2(in_between.y, -in_between.x)
		
		hurt_instance.position = middle
		hurt_instance.get_node("Right").direction = Vector2(spray.x,spray.y)
		spawn.call_deferred("add_child",hurt_instance)
		for i in (damage-1):
			var hurt_i_instance = hurt_instance.duplicate()
			spawn.call_deferred("add_child",hurt_i_instance)
		body.queue_free()

func update_lifebar():
	var lifebar = get_parent().get_node("UI/LifeBar")
	match life:
		0: 
			#No health => White
			lifebar.get_child(0).modulate = Color8(255,255,255)
			lifebar.get_child(1).modulate = Color8(255,255,255)
			lifebar.get_child(2).modulate = Color8(255,255,255)
			lifebar.get_child(3).modulate = Color8(255,255,255)
			lifebar.get_child(4).modulate = Color8(255,255,255)
			lifebar.get_child(5).modulate = Color8(255,255,255)
			lifebar.get_child(6).modulate = Color8(255,255,255)
			lifebar.get_child(7).modulate = Color8(255,255,255)
		1: 
			#1 PV => Red
			lifebar.get_child(0).modulate = Color8(255,255,255)
			lifebar.get_child(1).modulate = Color8(255,255,255)
			lifebar.get_child(2).modulate = Color8(255,255,255)
			lifebar.get_child(3).modulate = Color8(255,255,255)
			lifebar.get_child(4).modulate = Color8(255,255,255)
			lifebar.get_child(5).modulate = Color8(255,255,255)
			lifebar.get_child(6).modulate = Color8(255,255,255)
			lifebar.get_child(7).modulate = Color8(255,0,0)
			
		2: 
			#2 PV => Orange
			lifebar.get_child(0).modulate = Color8(255,255,255)
			lifebar.get_child(1).modulate = Color8(255,255,255)
			lifebar.get_child(2).modulate = Color8(255,255,255)
			lifebar.get_child(3).modulate = Color8(255,255,255)
			lifebar.get_child(4).modulate = Color8(255,255,255)
			lifebar.get_child(5).modulate = Color8(255,255,255)
			lifebar.get_child(6).modulate = Color8(255,165,0)
			lifebar.get_child(7).modulate = Color8(255,165,0)
			
		3: 
			#3 PV => Yellow
			lifebar.get_child(0).modulate = Color8(255,255,255)
			lifebar.get_child(1).modulate = Color8(255,255,255)
			lifebar.get_child(2).modulate = Color8(255,255,255)
			lifebar.get_child(3).modulate = Color8(255,255,255)
			lifebar.get_child(4).modulate = Color8(255,255,255)
			lifebar.get_child(5).modulate = Color8(255,255,0)
			lifebar.get_child(6).modulate = Color8(255,255,0)
			lifebar.get_child(7).modulate = Color8(255,255,0)
			
		4: 
			#4 PV => GreenYellow
			lifebar.get_child(0).modulate = Color8(255,255,255)
			lifebar.get_child(1).modulate = Color8(255,255,255)
			lifebar.get_child(2).modulate = Color8(255,255,255)
			lifebar.get_child(3).modulate = Color8(255,255,255)
			lifebar.get_child(4).modulate = Color8(173,255,47)
			lifebar.get_child(5).modulate = Color8(173,255,47)
			lifebar.get_child(6).modulate = Color8(173,255,47)
			lifebar.get_child(7).modulate = Color8(173,255,47)
			
		5: 
			#5 PV => Green
			lifebar.get_child(0).modulate = Color8(255,255,255)
			lifebar.get_child(1).modulate = Color8(255,255,255)
			lifebar.get_child(2).modulate = Color8(255,255,255)
			lifebar.get_child(3).modulate = Color8(0,255,0)
			lifebar.get_child(4).modulate = Color8(0,255,0)
			lifebar.get_child(5).modulate = Color8(0,255,0)
			lifebar.get_child(6).modulate = Color8(0,255,0)
			lifebar.get_child(7).modulate = Color8(0,255,0)
			
		6: 
			#6 PV => Green
			lifebar.get_child(0).modulate = Color8(255,255,255)
			lifebar.get_child(1).modulate = Color8(255,255,255)
			lifebar.get_child(2).modulate = Color8(0,255,0)
			lifebar.get_child(3).modulate = Color8(0,255,0)
			lifebar.get_child(4).modulate = Color8(0,255,0)
			lifebar.get_child(5).modulate = Color8(0,255,0)
			lifebar.get_child(6).modulate = Color8(0,255,0)
			lifebar.get_child(7).modulate = Color8(0,255,0)
			
		7: #7 PV => Green
			lifebar.get_child(0).modulate = Color8(255,255,255)
			lifebar.get_child(1).modulate = Color8(0,255,0)
			lifebar.get_child(2).modulate = Color8(0,255,0)
			lifebar.get_child(3).modulate = Color8(0,255,0)
			lifebar.get_child(4).modulate = Color8(0,255,0)
			lifebar.get_child(5).modulate = Color8(0,255,0)
			lifebar.get_child(6).modulate = Color8(0,255,0)
			lifebar.get_child(7).modulate = Color8(0,255,0)
			
		_: #Full health => Deep Sky Blue
			lifebar.get_child(0).modulate = Color8(0,191,255)
			lifebar.get_child(1).modulate = Color8(0,191,255)
			lifebar.get_child(2).modulate = Color8(0,191,255)
			lifebar.get_child(3).modulate = Color8(0,191,255)
			lifebar.get_child(4).modulate = Color8(0,191,255)
			lifebar.get_child(5).modulate = Color8(0,191,255)
			lifebar.get_child(6).modulate = Color8(0,191,255)
			lifebar.get_child(7).modulate = Color8(0,191,255)
