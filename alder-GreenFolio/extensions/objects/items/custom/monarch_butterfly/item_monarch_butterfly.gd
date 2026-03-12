extends ItemScriptActive
const GFUTIL := preload("res://mods-unpacked/alder-GreenFolio/GFsave_utils.gd")
const MonarchButterflyData := preload("res://mods-unpacked/alder-GreenFolio/extensions/objects/items/custom/monarch_butterfly/monarch_butterfly_data.gd")

var MONARCH_ITEM := load("res://mods-unpacked/alder-GreenFolio/extensions/objects/items/resources/passive/monarch_effects.tres")
var gf: Node = null

const POOL_SHORTHANDS := {
	"res://objects/items/pools/jellybeans.tres": "Jellybean",
	"res://objects/items/pools/super_candies.tres": "Super Candy",
	"res://objects/items/pools/candies.tres": "Candy",
	"res://mods-unpacked/alder-GreenFolio/extensions/objects/items/custom/monarch_butterfly/toonup12.tres": "Toonup",
	"res://objects/items/pools/treasures.tres": "Treasure"
}

var LOADED_POOLS := {}

const PARTICLE := preload("res://mods-unpacked/alder-GreenFolio/extensions/objects/battle/effects/monarch/monarchorbit.tscn")
const RAINBOW_SHADER := preload("res://mods-unpacked/alder-GreenFolio/extensions/objects/battle/effects/monarch/monarch_rainbow.gdshader")
const RAINBOW_BUTTERFLY_TEXTURE := preload("res://mods-unpacked/alder-GreenFolio/extensions/ui_assets/battle/statuses/monarch_butterfly/monarch_basic.png")
const RAINBOW_MASK_TEXTURE := preload("res://mods-unpacked/alder-GreenFolio/extensions/ui_assets/battle/statuses/monarch_butterfly/monarch_butterfly_colormask.png")

var _particle: GPUParticles3D = null
var _particle_mat: Material = null

func _ready() -> void:
	for path: String in POOL_SHORTHANDS.keys():
		var pool := load(path)
		if pool:
			LOADED_POOLS[path] = pool

	if OS.is_debug_build():
		var player := Util.get_player()
		if not player:
			return
		var atkstat: float = float(player.stats.damage)
		var everything: ItemPool = load("res://objects/items/pools/everything.tres")
		var results: Array[Dictionary] = []
		for item: Item in everything:
			var entry: Dictionary = {
				"qualitoon": int(item.qualitoon),
				"rarity": int(item.rarity),
				"evergreen": item.evergreen,
			}
			var shorthand: String = get_shorthand_label(item)
			var base_info: Dictionary = MonarchButterflyData.EFFECT_MAP.get(shorthand, { effect = "Basic", damage_multiplier = 1.0 })
			var effect_multiplier: float = float(base_info.damage_multiplier) if base_info.effect != "Random" else 1.0
			var effect_label: String = base_info.effect
			var damage: int = MonarchButterflyData.calculate_damage(entry, effect_multiplier, atkstat)
			results.append({ "name": item.item_name, "effect": effect_label, "damage": damage })
		results.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.damage > b.damage)
		print("=== Monarch Damage Test (atkstat: %s) (floor_number: %d)===" % [atkstat, Util.floor_number])
		for result: Dictionary in results:
			print("%s | effect: %s | damage: %d" % [result.name, result.effect, result.damage])
		print("=== End Monarch Damage Test ===")



func on_collect(_item: Item, _object: Node3D) -> void:
	super.on_collect(_item, _object)
	setup()

func on_load(_item: Item) -> void:
	setup()

func setup() -> void:
	gf = GFUTIL.get_gf()
	var player := Util.get_player()
	if not player or not gf:
		return

	if not player.stats.has_item("MonarchEffects"):
		var monarch = MONARCH_ITEM.duplicate(true)
		ItemService.seen_item(monarch)
		monarch.apply_item(player)

		var starting_butterflies: Array[Dictionary] = [
			{ "name": "The Monarch", "qualitoon": 3, "rarity": 0, "evergreen": false },
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

	_attach_world_particle()


func on_item_removed() -> void:
	_detach_world_particle()

func _attach_world_particle() -> void:
	var timer := Timer.new()
	timer.wait_time = 0.2
	timer.autostart = true
	timer.timeout.connect(_update_world_particle)
	add_child(timer)
	_update_world_particle()

func _detach_world_particle() -> void:
	if is_instance_valid(_particle):
		_particle.queue_free()
	_particle = null
	_particle_mat = null

func _update_world_particle() -> void:
	var world_item := ItemService.get_closest_item()

	if not world_item:
		_detach_world_particle()
		return

	if is_instance_valid(_particle) and _particle.get_parent() == world_item:
		_set_particle_texture(world_item.item)
		return

	_detach_world_particle()
	_particle = PARTICLE.instantiate() as GPUParticles3D
	world_item.add_child(_particle)
	_particle.transform.origin = Vector3.ZERO

	# Show one butterfly per absorbed copy for bulk items, otherwise 1
	var label := get_shorthand_label(world_item.item)
	var bulk: Dictionary = MonarchButterflyData.BULK_ABSORB.get(label, {})
	_particle.amount = bulk.get("count", 1)

	_particle_mat = _particle.draw_pass_1.material as StandardMaterial3D
	var shader := _particle.process_material as ShaderMaterial
	shader.set_shader_parameter("seed", int(RandomService.randf_range_channel("true_random", 1, 50000)))
	shader.set_shader_parameter("ORBIT_SPEED", 1.5)
	shader.set_shader_parameter("RADIUS", 0.9)
	shader.set_shader_parameter("HEIGHT", 0.25)


	_set_particle_texture(world_item.item)

func _set_particle_texture(item: Item) -> void:
	if not _particle:
		return
	var label := get_shorthand_label(item)
	var info: Dictionary = MonarchButterflyData.EFFECT_MAP.get(label, { effect = "Basic", damage_multiplier = 1.0 })
	var effect: String = info.get("effect", "Basic")

	if effect == "Random":
		var rainbow_mat := ShaderMaterial.new()
		rainbow_mat.shader = RAINBOW_SHADER
		rainbow_mat.set_shader_parameter("albedo_texture", RAINBOW_BUTTERFLY_TEXTURE)
		rainbow_mat.set_shader_parameter("mask_texture", RAINBOW_MASK_TEXTURE)
		_particle.draw_pass_1.material = rainbow_mat
		_particle_mat = rainbow_mat
	else:
		var std_mat := _particle.draw_pass_1.material as StandardMaterial3D
		if std_mat:
			std_mat.albedo_texture = MonarchButterflyData.BUTTERFLY_ICONS.get(effect, MonarchButterflyData.BUTTERFLY_ICONS["Default"])
			_particle_mat = std_mat

func validate_use() -> bool:
	var world_item := ItemService.get_closest_item()
	if not is_instance_valid(world_item):
		return false
	if can_absorb_item(world_item):
		return true
	var shop := get_parent_shop(world_item)
	if shop:
		var price := get_shop_price(shop, world_item)
		return price >= 0 and Util.get_player().stats.money >= price
	return false

func use() -> void:
	var world_item := ItemService.get_closest_item()
	if not is_instance_valid(world_item):
		return

	if can_absorb_item(world_item):
		var entry := _build_entry(world_item.item)
		gf.monarch_absorbed_items.append(entry)
		world_item.destroy_item()
		return

	# Shop item path
	var shop := get_parent_shop(world_item)
	if not shop:
		return

	var price := get_shop_price(shop, world_item)
	if price < 0 or Util.get_player().stats.money < price:
		return

	Util.get_player().stats.money -= price

	if shop.toon and shop.toon_speaks:
		shop.toon.speak(ToonShop.SALE_PHRASES.pick_random())

	var entry := _build_entry(world_item.item)
	gf.monarch_absorbed_items.append(entry)
	world_item.destroy_item()

func get_parent_shop(world_item: WorldItem) -> ToonShop:
	var parent := world_item.get_parent()
	while parent:
		if parent is ToonShop:
			return parent as ToonShop
		parent = parent.get_parent()
	return null

func get_shop_price(shop: ToonShop, world_item: WorldItem) -> int:
	var idx: int = shop.world_items.find(world_item)
	if idx < 0:
		return -1
	return shop.stored_prices.get(idx, -1)

func _build_entry(item: Item) -> Dictionary:
	var item_name := item.item_name
	if item_name in MonarchButterflyData.BULK_ABSORB:
		var bulk: Dictionary = MonarchButterflyData.BULK_ABSORB[item_name]
		var label := get_shorthand_label(item)
		var base_entry: Dictionary = { "name": label, "qualitoon": bulk.qualitoon, "rarity": 0, "evergreen": false }
		for i in range(int(bulk.count) - 1):
			gf.monarch_absorbed_items.append(base_entry.duplicate())
		return base_entry

	var is_evergreen: bool
	if item_name in MonarchButterflyData.EVERGREEN_OVERRIDES:
		is_evergreen = MonarchButterflyData.EVERGREEN_OVERRIDES[item_name]
	else:
		is_evergreen = item.evergreen

	return {
		"name": get_shorthand_label(item),
		"qualitoon": int(item.qualitoon),
		"rarity": int(item.rarity),
		"evergreen": is_evergreen,
	}

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
	
func can_absorb_item(world_item: WorldItem) -> bool:
	if not world_item.monitoring: return false
	elif world_item.get_node_or_null('CollisionShape3D') == null: 
		return false
	return true
