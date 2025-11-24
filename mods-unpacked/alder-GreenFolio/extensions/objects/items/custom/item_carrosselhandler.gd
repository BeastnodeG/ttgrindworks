extends ItemScript

var chest_cyclers: Dictionary = {}
var gf: Node = null

const REWARD_POOLS := [
	"res://objects/items/pools/rewards.tres",
	"res://objects/items/pools/special_items.tres",
	"res://objects/items/pools/doodle_treasure.tres"
]


func on_collect(_item: Item, _object: Node3D) -> void:
	setup()


func on_load(_item: Item) -> void:
	setup()


func on_item_removed() -> void:
	for chest in chest_cyclers.keys():
		var cycler = chest_cyclers[chest]
		cycler.stop_cycling()
	chest_cyclers.clear()


func setup() -> void:
	await getGF()
	Globals.s_chest_spawned.connect(on_chest_spawned)
	await get_tree().process_frame
	hook_existing_chests()


func getGF() -> void:
	if not is_inside_tree():
		await ready
	if not get_tree():
		return
	var path := "/root/ModLoader/alder-GreenFolio/GFglobal"
	var root := get_tree().get_root()
	if root and root.has_node(path):
		gf = root.get_node(path)


func hook_existing_chests() -> void:
	var root: Node
	if SceneLoader.current_scene:
		root = SceneLoader.current_scene
	else:
		root = Util.floor_manager.get_current_room()
	
	if not root:
		return
	
	var chests: Array[Node] = NodeGlobals.get_children_of_type(root, TreasureChest, true)
	
	for chest_node in chests:
		var chest := chest_node as TreasureChest
		if chest:
			on_chest_spawned(chest)


func on_chest_spawned(chest: TreasureChest) -> void:
	if chest.scripted_progression:
		return
	chest.s_opened.connect(setup_multi_item.bind(chest))


func is_reward_chest(chest: TreasureChest) -> bool:
	if not chest.item_pool:
		return false
	return chest.item_pool.resource_path in REWARD_POOLS


func get_item_count_for_chest(chest: TreasureChest) -> int:
	if not gf:
		return 1
	if is_reward_chest(chest):
		return gf.carrossel_reward_item_count
	else:
		return gf.carrossel_progressive_item_count


func get_cycle_duration_for_chest(chest: TreasureChest) -> float:
	if not gf:
		return 2.0
	if is_reward_chest(chest):
		return gf.carrossel_reward_cycle_duration
	else:
		return gf.carrossel_progressive_cycle_duration


func setup_multi_item(chest: TreasureChest) -> void:
	var item_count := get_item_count_for_chest(chest)
	
	if item_count <= 1:
		return
	
	var item_container = chest.get_node("Item")
	if item_container.get_child_count() == 0:
		return
	
	var first_world_item: WorldItem = item_container.get_child(0)
	var world_items: Array[WorldItem] = [first_world_item]
	
	var cycle_duration := get_cycle_duration_for_chest(chest)
	
	for i in range(item_count - 1):
		var new_world_item: WorldItem = chest.WORLD_ITEM.instantiate()
		new_world_item.override_replacement_rolls = chest.override_replacement_rolls
		new_world_item.pool = chest.item_pool
		
		if not chest.override_item:
			chest.assign_item(new_world_item)
		
		item_container.add_child(new_world_item)
		world_items.append(new_world_item)
		
		new_world_item.visible = false
		if new_world_item.has_node("MonitorTimer"):
			var timer = new_world_item.get_node("MonitorTimer")
			timer.stop()
			timer.queue_free()
		new_world_item.set_monitoring_deferred(false)
		new_world_item.get_node("ReactionArea").set_monitoring.call_deferred(false)
	
	var cycler = ChestCycler.new()
	cycler.world_items = world_items
	cycler.cycle_duration = cycle_duration
	cycler.current_index = 0
	
	chest_cyclers[chest] = cycler
	
	add_child(cycler)
	
	for world_item in world_items:
		world_item.s_collected.connect(stop_cycling.bind(chest))
		world_item.s_destroyed.connect(on_world_item_destroyed.bind(chest))
	
	cycler.start_cycling()

func stop_cycling(chest: TreasureChest) -> void:
	if chest in chest_cyclers:
		var cycler = chest_cyclers[chest]
		cycler.stop_cycling()
		chest_cyclers.erase(chest)


func on_world_item_destroyed(chest: TreasureChest) -> void:
	if chest in chest_cyclers:
		var cycler = chest_cyclers[chest]
		cycler.destroy_all()
		chest_cyclers.erase(chest)
		print("WORLD ITEM DESTROYED")


class ChestCycler extends Node:
	var world_items: Array[WorldItem] = []
	var current_index: int = 0
	var cycle_duration: float = 2.0
	var timer: Timer
	var is_cycling: bool = false
	var cycles_completed: int = 0
	var cycles_needed_for_delay: int = 0
	
	func start_cycling() -> void:
		if world_items.size() <= 1:
			return
		
		is_cycling = true
		
		cycles_needed_for_delay = ceili(1.0 / cycle_duration)
		
		timer = Timer.new()
		timer.wait_time = cycle_duration / world_items.size()
		timer.timeout.connect(cycle_to_next_item)
		add_child(timer)
		timer.start()
	
	func cycle_to_next_item() -> void:
		if not is_cycling or world_items.is_empty():
			return
		
		var previous_item = world_items[current_index]
		
		current_index = (current_index + 1) % world_items.size()
		
		if current_index == 0:
			cycles_completed += 1
		
		var next_item = world_items[current_index]
		
		if not is_instance_valid(next_item):
			return
		
		next_item.visible = true
		
		if cycles_completed >= cycles_needed_for_delay:
			next_item.set_monitoring_deferred(true)
			next_item.get_node("ReactionArea").set_monitoring.call_deferred(true)
		else:
			next_item.set_monitoring_deferred(false)
			next_item.get_node("ReactionArea").set_monitoring.call_deferred(false)
		
		if is_instance_valid(previous_item):
			previous_item.visible = false
			previous_item.set_monitoring_deferred(false)
			previous_item.get_node("ReactionArea").set_monitoring.call_deferred(false)
	
	func stop_cycling() -> void:
		is_cycling = false
		if timer:
			timer.stop()
			timer.queue_free()
		
		for i in range(world_items.size()):
			if i != current_index and is_instance_valid(world_items[i]):
				if world_items[i].item:
					ItemService.item_removed(world_items[i].item)
				world_items[i].queue_free()
	
	func destroy_all() -> void:
		is_cycling = false 
		if timer:
			timer.stop()
			timer.queue_free()
		
		for world_item in world_items:
			if is_instance_valid(world_item):
				if world_item.item:
					ItemService.item_removed(world_item.item)
				world_item.queue_free()
	
	func _exit_tree() -> void:
		stop_cycling()
