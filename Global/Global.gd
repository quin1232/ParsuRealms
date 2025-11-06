extends Node

## Emitted whenever the saved player transform changes
signal spawn_changed(new_transform: Transform3D)

## User Authentication Data
var player_email: String = ""
var player_username: String = ""
var is_guest: bool = false
var is_logged_in: bool = false

## Saved spawn data
var has_spawn: bool = false
var spawn_pos: Vector3 = Vector3.ZERO
var spawn_rot_y: float = 0.0  # yaw only
var scene_index: int = 0
var IsArrowClick: bool = false

var CEDfinish: bool = false
var CECfinish: bool = false
var COSfinish: bool = false
var CBMfinish: bool = false
var CAHfinish: bool = false
var SANGAYfinish: bool = false
var SANJOSEfinish: bool = false


# =========================
# Core API
# =========================

## Set from a full Transform3D (e.g., a CharacterBody3D's global_transform)
func set_player(t: Transform3D) -> void:
	spawn_pos = t.origin
	spawn_rot_y = t.basis.get_euler().y
	has_spawn = true
	emit_signal("spawn_changed", get_spawn_transform())

## Convenience: set directly from a Node3D
func set_player_from(node: Node3D) -> void:
	if node:
		set_player(node.global_transform)

## Set using raw values
func set_position_and_yaw(pos: Vector3, yaw_radians: float) -> void:
	spawn_pos = pos
	spawn_rot_y = yaw_radians
	has_spawn = true
	emit_signal("spawn_changed", get_spawn_transform())

## Get the saved transform (position + yaw only; no pitch/roll)
func get_spawn_transform() -> Transform3D:
	var t := Transform3D.IDENTITY
	t.origin = spawn_pos
	t.basis = Basis(Vector3.UP, spawn_rot_y)
	return t

## Clear the saved spawn
func clear_spawn() -> void:
	has_spawn = false
