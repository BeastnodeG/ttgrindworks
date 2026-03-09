extends Object
const GFUTIL := preload("res://mods-unpacked/alder-GreenFolio/GFsave_utils.gd")

func player_out_of_bounds(chain: ModLoaderHookChain, player: Player) -> void:	
	if player.has_meta("stuck") or player.global_position.y <= -1000:
		print("lets execute next")
		chain.execute_next([player])

func _ready(chain: ModLoaderHookChain) -> void:
	var gf = GFUTIL.get_gf()
	
	if gf.folio_level >= 1:
		var debug_anomalies = chain.reference_object.debug_anomalies #this is hacky. oh well !
		#debug_anomalies.append(load("res://mods-unpacked/alder-GreenFolio/extensions/scenes/game_floor/floor_modifiers/scripts/anomalies/floor_mod_itemcycletest.gd"))
		debug_anomalies.append(load("res://mods-unpacked/alder-GreenFolio/extensions/objects/thegreenfolio/floor_mod_thegreenfolio.gd"))
	chain.execute_next()
	
func append_room(chain: ModLoaderHookChain, room: PackedScene, room_type) -> void:
	print("loading room:", room.resource_path)
	chain.execute_next([room, room_type])
