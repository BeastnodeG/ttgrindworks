extends ItemScriptActive

var MONARCH_ITEM := load("res://mods-unpacked/alder-GreenFolio/extensions/objects/items/resources/passive/monarch_effects.tres")
var gf : Node = null

const POOL_SHORTHANDS := {
	"res://objects/items/pools/jellybeans.tres": "Jellybean",
	"res://objects/items/pools/super_candies.tres": "Super Candy",
	"res://objects/items/pools/candies.tres": "Candy",
	"res://mods-unpacked/alder-GreenFolio/extensions/objects/items/custom/monarch_butterfly/toonup12.tres": "Toonup",
	"res://objects/items/pools/treasures.tres": "Treasure"
}

var LOADED_POOLS := {}

func _ready() -> void:
	for path: String in POOL_SHORTHANDS.keys():
		var pool := load(path)
		if pool:
			LOADED_POOLS[path] = pool

func on_collect(_item: Item, _object: Node3D) -> void:
	super.on_collect(_item, _object)
	setup()

func setup() -> void:
	getGF()
	var player := Util.get_player()
	if not player or not gf:
		return

	if not player.stats.has_item("MonarchEffects"):
		var monarch = MONARCH_ITEM.duplicate(true)
		ItemService.seen_item(monarch)
		monarch.apply_item(player)

		var starting_butterflies: Array[Dictionary] = [
			{ "name": "The Monarch", "qualitoon": 1 },
		]
		for butterfly: Dictionary in starting_butterflies:
			var exists := false
			for existing in gf.monarch_absorbed_items:
				if existing.get("name", "") == butterfly.get("name", ""):
					exists = true
					break

			if not exists:
				gf.monarch_absorbed_items.append(butterfly)
				print("Added starting butterfly: %s" % butterfly)
			else:
				print("Skipped duplicate butterfly: %s" % butterfly)


func getGF() -> void:
	if not is_inside_tree():
		await ready
	if not get_tree():
		print("get_tree() is null!")
		return

	var path := "/root/ModLoader/alder-GreenFolio/GFglobal"
	var root := get_tree().get_root()
	if root and root.has_node(path):
		gf = root.get_node(path)
		print("Loaded GFglobal")
	else:
		print("GFglobal not found at", path)

func validate_use() -> bool:
	return ItemService.get_closest_item() != null

func use() -> void:
	var player := Util.get_player()

	var world_item := ItemService.get_closest_item()

	var item_name := world_item.item.item_name
	var absorbed_list: Array[Dictionary] = gf.monarch_absorbed_items

	if item_name == "Gag Point Boost":
		for i in range(12):
			var entry := {
				"name": "Random",
				"qualitoon": 2
			}
			absorbed_list.append(entry)
	elif item_name == "Extra Turn":
		for i in range(7):
			var entry := {
				"name": "Random",
				"qualitoon": 2
			}
			absorbed_list.append(entry)
	elif item_name == "Accessory Trunk":
		for i in range(4):
			var entry := {
				"name": "Random",
				"qualitoon": 1
			}
			absorbed_list.append(entry)
	elif item_name == "???":
		for i in range(4):
			var entry := {
				"name": "Random",
				"qualitoon": 1
			}
			absorbed_list.append(entry)
	elif item_name == "Monarch Butterfly":
		for i in range(20):
			var entry := {
				"name": "Random",
				"qualitoon": 1
			}
			absorbed_list.append(entry)
	else:
		var shorthand := get_shorthand_label(world_item.item)
		var qualitoon := str(world_item.item.qualitoon)

		var entry := {
			"name": shorthand,
			"qualitoon": qualitoon
		}
		absorbed_list.append(entry)
		print("Absorbed item: %s" % entry)

	world_item.destroy_item()

func get_shorthand_label(item: Item) -> String:
	if "arbitrary_data" in item:
		var data: Dictionary = item.arbitrary_data
		if "track" in data:
			var track_name := str(data["track"])
			print("Track Label:", track_name)
			return track_name

	for path: String in LOADED_POOLS:
		var pool: ItemPool = LOADED_POOLS[path]
		if item_in_pool(item, pool):
			return POOL_SHORTHANDS[path]

	return item.item_name

func item_in_pool(item: Item, pool: ItemPool) -> bool:
	for pool_item: Item in pool:
		if pool_item.item_name == item.item_name:
			return true
	return false
