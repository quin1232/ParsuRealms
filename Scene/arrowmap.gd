extends TextureRect

@export var move_distance: float = 20.0   # how far to move left/right (pixels)
@export var speed: float = 4.0            # how fast to move
var _origin_x: float

func _ready() -> void:
	# store starting position
	_origin_x = position.x
	visible = false

func _process(delta: float) -> void:
	# oscillate back and forth using sine wave
	var offset = sin(Time.get_ticks_msec() / 1000.0 * speed) * move_distance
	position.x = _origin_x + offset
