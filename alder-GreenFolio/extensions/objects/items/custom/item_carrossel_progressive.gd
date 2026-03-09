extends ItemScript
const GFUTIL := preload("res://mods-unpacked/alder-GreenFolio/GFsave_utils.gd")

var gf: Node = null
var ITEM_CYCLER := load("res://mods-unpacked/alder-GreenFolio/extensions/objects/items/resources/passive/itemcycler.tres")


func on_collect(_item: Item, _object: Node3D) -> void:
	setup()

func on_item_removed() -> void:
	gf.carrossel_progressive_item_count -= 1
	#gf.carrossel_reward_item_count -= 1

func setup() -> void:
	gf = GFUTIL.get_gf()
	
	var player := Util.get_player()
	if not player:
		return
	
	if not player.stats.has_item("Item Cycler"): #hidden items are cool res://mods-unpacked/alder-GreenFolio/extensions/objects/items/resources/passive/itemcycler.tres
		var cycler = ITEM_CYCLER.duplicate(true)
		ItemService.seen_item(cycler)
		cycler.apply_item(player)
	
	gf.carrossel_progressive_item_count += 1
	#gf.carrossel_reward_item_count += 1



