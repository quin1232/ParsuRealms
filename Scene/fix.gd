# FixButton.gd
extends TextureButton

@export var loading_control_path: NodePath
@export var fake_duration: float = 2.4
@export var loading_text: String = "Fixing"
@export var carclose: AnimationPlayer

var _loading: Node = null

func _ready() -> void:
	_loading = get_node_or_null(loading_control_path)
	# Connect our own pressed signal
	self.pressed.connect(_on_pressed)

func _on_pressed() -> void:
	if Dialogic.VAR.CollectComplete != true:
		Dialogic.start("notComplete")
		return

	if _loading.has_method("start_loading"):
		disabled = true
		self.hide()

		# Show the loading overlay
		if _loading.has_method("show"):
			_loading.call("show")

		# Connect once to the loading_done signal (Godot 4 style)
		if _loading.has_signal("loading_done"):
			var cb := Callable(self, "_on_loading_done")
			if not _loading.is_connected("loading_done", cb):
				_loading.connect("loading_done", cb, Object.CONNECT_ONE_SHOT)

		# Kick off the fake loading
		_loading.call("start_loading", fake_duration, loading_text)
	else:
		push_warning("FixButton: target has no 'start_loading' method.")

func _on_loading_done() -> void:
	disabled = false

	# Prefer the loading control's stop method if available; otherwise just hide it.
	if _loading:
		if _loading.has_method("stop_and_hide"):
			_loading.call("stop_and_hide")
		elif _loading.has_method("hide_loading"):
			_loading.call("hide_loading")
		elif _loading.has_method("hide"):
			_loading.call("hide")
	Dialogic.VAR.CECquestComplete = true
	Dialogic.start("CEC", "CECquestComplete")
