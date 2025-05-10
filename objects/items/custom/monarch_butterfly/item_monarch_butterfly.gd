extends ItemScriptActive

const MONARCH_ITEM_PATH := "res://objects/items/resources/passive/monarch_effects.tres"
const MONARCH_ITEM := preload(MONARCH_ITEM_PATH)
const MonarchRegistry = preload("res://objects/items/custom/monarch_butterfly/monarch_registry.gd") # adjust the path as needed

const POOL_SHORTHANDS := {
	"res://objects/items/pools/jellybeans.tres": "Jellybean",
	"res://objects/items/pools/super_candies.tres": "Super Candy",
	"res://objects/items/pools/candies.tres": "Candy",
	"res://objects/items/custom/monarch_butterfly/toonup.tres": "Toonup",
	"res://objects/items/pools/treasures.tres": "Treasure"
}

var LOADED_POOLS := {}
var absorbed_items: Array[Dictionary] = []

func _ready() -> void:
	for path in POOL_SHORTHANDS.keys():
		var pool := load(path)
		if pool:
			LOADED_POOLS[path] = pool

func on_collect(_item: Item, _object: Node3D) -> void:
	super.on_collect(_item, _object)
	setup()

func setup() -> void:
	var player = Util.get_player()
	if not player or not player.stats:
		return

	if not player.stats.has_item("MonarchEffects"):
		var monarch = MONARCH_ITEM.duplicate()
		ItemService.seen_item(monarch)
		monarch.apply_item(player)

		# Define an array of starting butterflies
		var starting_butterflies := [
			{ "name": "Dragon Wings", "qualitoon": 1 },
			{ "name": "Jellybean", "qualitoon": 1 },
			{ "name": "Super Candy", "qualitoon": 1 },
			{ "name": "Awesome", "qualitoon": 1 },
			{ "name": "Fedora", "qualitoon": 1 },
			{ "name": "Witch Hat", "qualitoon": 1 },
			{ "name": "Throw", "qualitoon": 1 },
			{ "name": "Drop", "qualitoon": 1 },
			{ "name": "Toonup", "qualitoon": 1 },
			{ "name": "Squirt", "qualitoon": 1 },
			{ "name": "Princess Hat", "qualitoon": 1 }
		]

		# Append each starting butterfly to absorbed_items
		for butterfly in starting_butterflies:
			absorbed_items.append(butterfly)
			print("Added starting butterfly: %s" % butterfly)

		# Save to registry
		MonarchRegistry.set_absorbed_items(absorbed_items)


func use() -> void:
	var world_item := ItemService.get_closest_item()
	if not world_item or not world_item.has_node("CollisionShape3D"):
		cancel_use()
		return

	var item_name := world_item.item.item_name

	if item_name == "Gag Point Boost":
		for i in range(7):
			var entry := {
				"name": "Random",
				"qualitoon": 2
			}
			absorbed_items.append(entry)
		print("Added Gag Point entry.")
	elif item_name == "Extra Turn":
		for i in range(7):
			var entry := {
				"name": "Random",
				"qualitoon": 1
			}
			absorbed_items.append(entry)
		print("Added Extra Turn entry.")
	else:
		var shorthand := get_shorthand_label(world_item.item)
		var qualitoon := str(world_item.item.qualitoon)

		var entry := {
			"name": shorthand,
			"qualitoon": qualitoon
		}
		absorbed_items.append(entry)
		print("Absorbed item and updated registry: %s" % entry)

	MonarchRegistry.set_absorbed_items(absorbed_items)

	var dust_cloud = Globals.DUST_CLOUD.instantiate()
	world_item.get_parent().add_child(dust_cloud)
	dust_cloud.scale *= world_item.scale
	dust_cloud.global_position = world_item.global_position

	world_item.queue_free()

func get_shorthand_label(item: Item) -> String:
	# Priority: arbitrary_data.track
	if "arbitrary_data" in item:
		var data: Dictionary = item.arbitrary_data
		if "track" in data:
			var track_name := str(data["track"])
			print("Track Label:", track_name)
			return track_name

	# Check known pools next
	for path in LOADED_POOLS:
		var pool: ItemPool = LOADED_POOLS[path]
		if item_in_pool(item, pool):
			return POOL_SHORTHANDS[path]

	# Default fallback
	return item.item_name


	# Check known pools next
	for path in LOADED_POOLS:
		var pool: ItemPool = LOADED_POOLS[path]
		if item_in_pool(item, pool):
			return POOL_SHORTHANDS[path]

	# Default fallback
	return item.item_name

func item_in_pool(item: Item, pool: ItemPool) -> bool:
	for pool_item: Item in pool.items:
		if pool_item.item_name == item.item_name:
			return true
	return false
