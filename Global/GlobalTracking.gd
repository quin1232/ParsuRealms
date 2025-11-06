extends Node

var selected_campus: int = -1
var selected_college: int = -1


func set_campus(i: int) -> void:
	selected_campus = i;

func set_college(i: int) -> void:
	selected_college = i

func get_selected_campus() -> int:
	return selected_campus

func get_selected_college() -> int:
	return selected_college
