extends FloorModifier

var gf : Node = null
var floor_num := Util.floor_number

var proxy_effect : StatusEffect = preload("res://objects/battle/battle_resources/status_effects/mod_cog_effects/status_effect_mod_cog.gd").new()
var stat_boost : StatusEffect = preload("res://objects/battle/battle_resources/status_effects/stat_boost.gd").new()
var gag_immunity : StatusEffect = preload("res://objects/battle/battle_resources/status_effects/gag_immunity.gd").new()

const PRICE_HIKE := 0.25
const FLOOR_TAG := 'shop_inflation'

#this is going to make you sick but...
#folio 6 - player.hooks.gd
#folio 4 - floor_variants.hooks.gd
#folio 10 - barrel_room.hooks.gd
#folio 1, 2, 3, 5, 7, 8, 9 - all done in this script wahoo!!!
#folio 3 has some additional balancing in status_effect_mod_cog.hooks.gd

#folio 7?

func modify_floor() -> void:
	getGF()
	print("um... i'd.. like... to introduce-you to my gf!!: ", gf) #i'm... so proud of him
	
	if gf.folio_level >= 5:
		apply_folio5()
		
	if gf.folio_level >= 8: #folio 8
		Globals.MaxToonupConsumables = 1
		pass
	else: if gf.folio_level >= 2: #folio 2
		Globals.MaxToonupConsumables = 3
		pass
	
	print("max toonup consumables is like ", Globals.MaxToonupConsumables)
	
	BattleService.s_battle_started.connect(on_battle_start)
	BattleService.s_battle_spawned.connect(apply_folio1) #folio 1 force proxy spawn per battle
	
func on_battle_start(battle : BattleManager) -> void:
	for cog in battle.cogs:
		if (cog.dna.is_admin and gf.folio_level >= 3 and floor_num != 0 and floor_num != 6) \
		or (cog.dna.is_mod_cog and gf.folio_level >= 7):
			apply_folio3_7(cog)

		if gf.folio_level >= 9: 
			apply_folio9(cog)

	await Util.s_process_frame
	BattleService.s_refresh_statuses.emit()
	BattleService.ongoing_battle.battle_ui.cog_panels.reset(0)
	BattleService.ongoing_battle.battle_ui.cog_panels.assign_cogs(BattleService.ongoing_battle.cogs)

	battle.s_participant_joined.connect(participant_joined)
	pass


func participant_joined(cog : Cog) -> void:
	print("printing joined participant: ", cog)
	if gf.folio_level >= 9 and cog.dna.is_admin == false:
		apply_folio9(cog)
	pass

func apply_folio1(battle: BattleNode) -> void: # folio 1, guarantee proxy spawns
	print("battle spawn detected")
	var has_proxy := false
	var admin := false
	var admin_cog
	for cog in battle.cogs:
		if cog.dna.is_mod_cog:
			has_proxy = true
		if cog.dna.is_admin:
			has_proxy = true
			admin_cog = cog
			admin = true
	print("battles has proxy: ", has_proxy, " ", battle.cogs.size)
	if not has_proxy:
		var cog = battle.cogs[RNG.channel(&"forced_proxy").randi() % battle.cogs.size()]
		cog.dna = null
		battle.mod_cogs += 1
		cog.use_mod_cogs_pool = true
		await cog.randomize_cog()
		print("printing floor num ", floor_num)
		if floor_num == 0: #you're welcome lol - we run this after randomize because level is cleared otherwise
			if battle.cogs.size() == 1:
				print("this one gets to be level 2 because battle size is, ", battle.cogs.size)
				cog.level = 2
			else:
				cog.level = 1
			cog.set_up_stats()
			print(cog.level)
			print(cog.stats.hp)
		#if admin == true: #and not floor_num == 0:
			#print("admin cog detected, giving a proxy buff")
			#var effect : StatusEffect = proxy_effect.duplicate(true)
			#admin_cog.dna.status_effects.append(effect)
			#pass

func apply_folio3_7(cog: Cog) -> void: # folio 3, give admins proxy effects folio 7, give proxies an addition proxy effect
	print("trying to give a proxy effect because of green folio")
	var effect : StatusEffect = proxy_effect.duplicate(true)
	effect.target = cog
	BattleService.ongoing_battle.add_status_effect(effect)
	await Util.s_process_frame
	print("printing status effects", BattleService.ongoing_battle.status_effects)
	print(BattleService.ongoing_battle.status_effects)
	BattleService.ongoing_battle.status_effects.erase(effect) #remove it because otherwise it keeps a empty status effect around
	pass

func apply_folio5() -> void:
	if FLOOR_TAG in game_floor.floor_tags:
		game_floor.floor_tags[FLOOR_TAG] += PRICE_HIKE
	else:
		game_floor.floor_tags[FLOOR_TAG] = 1.0 + PRICE_HIKE
	pass

func apply_folio9(cog: Cog) -> void: # folio 9, add a random defense, damage, or gag immunity
	print("trying to give cog a buff because green folio")

	# Options include defense, damage, and gag immunity, but floor 0 cannot get gag immunity
	var options := ["defense", "damage", "accuracy"]
	if floor_num != 0:
		options.append("gag_immunity")

	var index := RNG.channel(&"cog_stat_bonus").randi() % options.size()
	var choice : String = options[index] as String

	if choice == "gag_immunity":
		var effect : StatusEffect = gag_immunity.duplicate(true)
		effect.target = cog
		effect.quality = StatusEffect.EffectQuality.POSITIVE
		effect.randomize_effect()
		effect.rounds = -1
		BattleService.ongoing_battle.add_status_effect(effect)
	else:
		var effect : StatusEffect = stat_boost.duplicate(true)
		effect.target = cog
		effect.rounds = -1
		effect.boost = 0.1
		effect.quality = StatusEffect.EffectQuality.POSITIVE
		effect.stat = choice
		#if choice == "accuracy":
			#effect.icon = load("res://mods-unpacked/alder-GreenFolio/extensions/ui_assets/player_ui/pause/accuracy.png")
		BattleService.ongoing_battle.add_status_effect(effect)

	await Util.s_process_frame
	print("printing status effects", BattleService.ongoing_battle.status_effects)
	print(BattleService.ongoing_battle.status_effects)



func apply_random_effect(cog : Cog) -> void:
	pass

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

func get_mod_name() -> String:
	return "Folio - %d" % gf.folio_level

func get_description() -> String:
	var path := "res://mods-unpacked/alder-GreenFolio/extensions/objects/thegreenfolio/folios.json"
	var file := FileAccess.open(path, FileAccess.READ)
	var data := file.get_as_text()
	file.close()
	var json_parser := JSON.new()
	json_parser.parse(data)
	var folio_texts : Array = json_parser.get_data()
	var level : int = clamp(gf.folio_level, 0, folio_texts.size() - 1)
	var descriptions : Array[String] = []
	for i in range(1, level + 1):
		descriptions.append(folio_texts[i])
		
	var filtered : Array[String] = []
	var last_toonup_idx := -1
	for i in range(descriptions.size()):
		if descriptions[i].begins_with("Toonup carry max reduced"):
			last_toonup_idx = i
	for i in range(descriptions.size()):
		if descriptions[i].begins_with("Toonup carry max reduced"):
			if i == last_toonup_idx:
				filtered.append(descriptions[i])
		else:
			filtered.append(descriptions[i])
	return "\n".join(filtered)


func get_mod_icon() -> Texture2D:
	return load("res://mods-unpacked/alder-GreenFolio/extensions/objects/thegreenfolio/thegreenfolio.png")

func get_mod_quality() -> ModType:
	return ModType.NEUTRAL
