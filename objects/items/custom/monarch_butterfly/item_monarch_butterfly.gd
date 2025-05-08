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
	# Load all the item pools
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

func use() -> void:
	var world_item := ItemService.get_closest_item()
	if not world_item or not world_item.has_node("CollisionShape3D"):
		cancel_use()
		return

	var shorthand := get_shorthand_label(world_item.item)
	var qualitoon := ""
	qualitoon = str(world_item.item.qualitoon)

	var entry := {
		"name": shorthand,
		"qualitoon": qualitoon
	}
	absorbed_items.append(entry)
	MonarchRegistry.set_absorbed_items(absorbed_items)
	print("Absorbed item and updated registry: %s" % entry)

	var dust_cloud = Globals.DUST_CLOUD.instantiate()
	world_item.get_parent().add_child(dust_cloud)
	dust_cloud.scale *= world_item.scale
	dust_cloud.global_position = world_item.global_position

	world_item.queue_free()


func get_shorthand_label(item: Item) -> String:
	for path in LOADED_POOLS:
		var pool: ItemPool = LOADED_POOLS[path]
		if item_in_pool(item, pool):
			return POOL_SHORTHANDS[path]
	return item.item_name

func item_in_pool(item: Item, pool: ItemPool) -> bool:
	for pool_item: Item in pool.items:
		if pool_item.item_name == item.item_name:
			return true
	return false
