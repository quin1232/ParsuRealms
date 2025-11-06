extends Label

@export var move_distance: float = 2.0   # how far to move up/down
@export var speed: float = 3.0           # how fast to move
var _origin_y: float
var _time: float = 0.0

func _ready() -> void:
	_origin_y = position.y

func _process(delta: float) -> void:
	_time += delta * speed
	var offset = sin(_time) * move_distance
	position.y = _origin_y + offset
