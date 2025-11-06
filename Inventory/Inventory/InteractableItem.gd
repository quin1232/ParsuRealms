extends Node3D
class_name InteractableItem

@export var ItemHighlightMesh : MeshInstance3D


func GainFocus():
	if ItemHighlightMesh:
		ItemHighlightMesh.visible = true

func LoseFocus():
	if ItemHighlightMesh:
		ItemHighlightMesh.visible = false
