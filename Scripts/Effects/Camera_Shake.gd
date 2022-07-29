extends Camera2D

export var shakeBaseAmount = 1.0
export var shakeDamp = 0.075

var shakeAmount = 0.0

func _process(_delta):
	if shakeAmount > 0:
		position.x = rand_range(-shakeBaseAmount,shakeBaseAmount) * shakeAmount
		position.y = rand_range(-shakeBaseAmount,shakeBaseAmount) * shakeAmount
		shakeAmount = lerp(shakeAmount, 0.0, shakeDamp)
	else:
		position = Vector2(0,0)


func shake(magnitude : float):
	shakeAmount += magnitude
