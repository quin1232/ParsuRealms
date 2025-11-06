extends Node3D

func _ready():
	# Defer fade to next frame to allow scene to fully load first
	call_deferred("_start_fade")
	# Start animation after a slight delay for better performance
	get_tree().create_timer(0.1).timeout.connect(_play_animation)
	$SoundEffects/Intro.play()

func _start_fade():
	FadeLayer.fade_in()

func _play_animation():
	$AnimationPlayer.play("openclouds")
