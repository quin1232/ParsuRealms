extends Area3D

@export var allowed_body: Node3D
@export var talk: TextureButton
@onready var anim : AnimationPlayer = $"../AnimationPlayer"

func _on_body_entered(body: Node3D) -> void:
	if allowed_body != body:
		return
	talk.show()
	
	
	


func _on_body_exited(body: Node3D) -> void:
	talk.hide()
	anim.play("Idle")
