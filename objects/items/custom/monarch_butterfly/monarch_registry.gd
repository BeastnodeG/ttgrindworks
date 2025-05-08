extends Object
class_name MonarchRegistry

static var absorbed_items: Array[Dictionary] = []

static func set_absorbed_items(new_items: Array[Dictionary]) -> void:
	absorbed_items = new_items.duplicate()
	print("Registry absorbed array: %s" % absorbed_items)

static func get_absorbed_items() -> Array[Dictionary]:
	return absorbed_items.duplicate()
