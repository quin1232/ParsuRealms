extends StaticBody3D

@onready var anim_tree: AnimationTree = $AnimationTrees
@onready var playback: AnimationNodeStateMachinePlayback = anim_tree.get("parameters/playback")

const P_IS_WAVING := "parameters/conditions/is_waving"  # ✅ correct path

func _ready() -> void:
	anim_tree.active = true
	playback.start("Idle")
	anim_tree.set(P_IS_WAVING, false)

# Call this to trigger Wave via the condition
func play_wave() -> void:
	anim_tree.set(P_IS_WAVING, true)
	# safety: if the transition isn’t wired, force it
	if playback.get_current_node() != "Wave":
		playback.travel("Wave")

# Call this to go back to Idle (if you didn’t set auto-return)
func stop_wave() -> void:
	anim_tree.set(P_IS_WAVING, false)
