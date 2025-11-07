extends Node3D

func _ready():
	# Defer fade to next frame to allow scene to fully load first
	call_deferred("_start_fade")
	# Start animation after a slight delay for better performance
	get_tree().create_timer(0.1).timeout.connect(_play_animation)
	$SoundEffects/Intro.play()

	# Display logged-in username
	var user = Database.db_manager.get_current_user()
	var username = ""
	if user.has("user_metadata") and user["user_metadata"].has("username"):
		username = user["user_metadata"]["username"]
	elif user.has("username"):
		username = user["username"]
	if username != "":
		$CanvasLayer/TextureRect/playername.text = username # Change this path if your label node is different

func _start_fade():
	FadeLayer.fade_in()

func _play_animation():
	$AnimationPlayer.play("openclouds")
