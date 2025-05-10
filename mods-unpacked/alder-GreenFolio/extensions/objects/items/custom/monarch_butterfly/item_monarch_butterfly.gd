extends ItemScriptActive

var MONARCH_ITEM := load("res://objects/items/resources/passive/monarch_effects.tres")

const POOL_SHORTHANDS := {
	"res://objects/items/pools/jellybeans.tres": "Jellybean",
	"res://objects/items/pools/super_candies.tres": "Super Candy",
	"res://objects/items/pools/candies.tres": "Candy",
	"res://objects/items/custom/monarch_butterfly/toonup.tres": "Toonup",
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
	var player := Util.get_player()
	if not player or not player.stats:
		return

	if not player.stats.has_item("MonarchEffects"):
		var monarch = MONARCH_ITEM.duplicate()
		ItemService.seen_item(monarch)
		monarch.apply_item(player)

		var starting_butterflies: Array[Dictionary] = [
			{ "name": "The Monarch", "qualitoon": 1 },
		]
		for butterfly: Dictionary in starting_butterflies:
			var exists := false
			for existing in player.stats.monarch_absorbed_items:
				if existing.get("name", "") == butterfly.get("name", ""):
					exists = true
					break

			if not exists:
				player.stats.monarch_absorbed_items.append(butterfly)
				print("Added starting butterfly: %s" % butterfly)
			else:
				print("Skipped duplicate butterfly: %s" % butterfly)


func use() -> void:
	var player := Util.get_player()
	if not player or not player.stats:
		cancel_use()
		return

	var world_item := ItemService.get_closest_item()
	if not world_item or not world_item.has_node("CollisionShape3D"):
		cancel_use()
		return

	var item_name := world_item.item.item_name
	var absorbed_list: Array[Dictionary] = player.stats.monarch_absorbed_items

	if item_name == "Gag Point Boost":
		for i in range(7):
			var entry := {
				"name": "Random",
				"qualitoon": 2
			}
			absorbed_list.append(entry)
	elif item_name == "Extra Turn":
		for i in range(7):
			var entry := {
				"name": "Random",
				"qualitoon": 1
			}
			absorbed_list.append(entry)
	elif item_name == "Monarch Butterfly":
		for i in range(15):
			var entry := {
				"name": "Basic",
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

	var dust_cloud = Globals.DUST_CLOUD.instantiate()
	world_item.get_parent().add_child(dust_cloud)
	dust_cloud.scale *= world_item.scale
	dust_cloud.global_position = world_item.global_position

	world_item.queue_free()

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
	for pool_item: Item in pool.items:
		if pool_item.item_name == item.item_name:
			return true
	return false
