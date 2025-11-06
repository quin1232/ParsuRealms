extends ParallaxLayer

var speed = Vector2(8, 0) # Adjust speed here

# Use _physics_process for smoother, more predictable movement
func _physics_process(delta):
	motion_offset += speed * delta
