extends ItemScript

var gf: Node = null
var ITEM_CYCLER := load("res://mods-unpacked/alder-GreenFolio/extensions/objects/items/resources/passive/itemcycler.tres")


func on_collect(_item: Item, _object: Node3D) -> void:
	setup()

func on_item_removed() -> void:
	gf.carrossel_progressive_item_count -= 1
	#gf.carrossel_reward_item_count -= 1

func setup() -> void:
	await getGF()
	
	var player := Util.get_player()
	if not player:
		return
	
	if not player.stats.has_item("Item Cycler"): #hidden items are cool res://mods-unpacked/alder-GreenFolio/extensions/objects/items/resources/passive/itemcycler.tres
		var cycler = ITEM_CYCLER.duplicate(true)
		ItemService.seen_item(cycler)
		cycler.apply_item(player)
	
	gf.carrossel_progressive_item_count += 1
	#gf.carrossel_reward_item_count += 1


func getGF() -> void:
	if not is_inside_tree():
		await ready
	if not get_tree():
		return
	var path := "/root/ModLoader/alder-GreenFolio/GFglobal"
	var root := get_tree().get_root()
	if root and root.has_node(path):
		gf = root.get_node(path)
