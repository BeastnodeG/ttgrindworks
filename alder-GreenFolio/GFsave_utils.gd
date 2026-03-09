class_name GFsave_utils

const PATH := "/root/ModLoader/alder-GreenFolio/GFglobal"
const PATH_PROGRESS := "/root/ModLoader/alder-GreenFolio/GFprogress"

static func get_gf() -> Node:
	var tree = Engine.get_main_loop()
	if tree:
		return tree.root.get_node_or_null(PATH)
	return null

static func get_progress() -> Node:
	var tree = Engine.get_main_loop()
	if tree:
		return tree.root.get_node_or_null(PATH_PROGRESS)
	return null
