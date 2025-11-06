extends Node3D

@export var move_distance: float = 2.0   # how far to move up/down
@export var speed: float = 3.0           # how fast to move
var _origin_y: float

func _ready() -> void:
	# store starting position
	_origin_y = position.y

func _process(delta: float) -> void:
	# oscillate up and down using sine wave
	var offset = sin(Time.get_ticks_msec() / 1000.0 * speed) * move_distance
	position.y = _origin_y + offset
