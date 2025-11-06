extends Area3D

signal OnItemPickedUp(item)
signal nearby_changed(has_nearby: bool)
@export var ItemTypes : Array[ItemData] = []

var NearbyBodies : Array[InteractableItem]


func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("Interact")):
		PickupNearestItem()

func PickupNearestItem():
	var nearestItem: Node3D = null
	var nearestItemDistance: float = INF

	for item in NearbyBodies:
		var dist := item.global_position.distance_to(global_position)
		if dist < nearestItemDistance:
			nearestItemDistance = dist
			nearestItem = item

	if nearestItem == null:
		return

	# Save prefab path before freeing
	var itemPrefab: String = nearestItem.scene_file_path

	# Remove and free
	NearbyBodies.erase(nearestItem)
	nearestItem.queue_free()

	# Match prefab to ItemData
	for i in range(ItemTypes.size()):
		var data = ItemTypes[i]
		if data != null and data.ItemModelPrefab != null and data.ItemModelPrefab.resource_path == itemPrefab:
			print("Item id:%d  Item Name:%s" % [i, data.ItemName])
			OnItemPickedUp.emit(data)
			return

	printerr("Item not found for prefab: ", itemPrefab)

func OnObjectEnteredArea(body: Node3D):
	if body is InteractableItem:
		body.GainFocus()
		if not NearbyBodies.has(body):
			NearbyBodies.append(body)
		nearby_changed.emit(NearbyBodies.size() > 0)

func OnObjectExitedArea(body: Node3D):
	if body is InteractableItem and NearbyBodies.has(body):
		body.LoseFocus()
		NearbyBodies.erase(body)
		nearby_changed.emit(NearbyBodies.size() > 0)
