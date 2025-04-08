extends AnimatedSprite3D

@export var fade_duration: float = 2.0  # Time to fade from white to black
var time_passed: float = 0.0
var fading: bool = true

func _ready():
	modulate = Color.WHITE  # Start at white

func _process(delta: float):
	if fading:
		time_passed += delta
		var t = clamp(time_passed / fade_duration, 0.0, 1.0)
		modulate = Color(1.0 - t, 1.0 - t, 1.0 - t)  # Linearly go from white to black

		if t >= 1.0:
			fading = false
