extends Node

var seed_label: Label

func sync_reward(chain: ModLoaderHookChain) -> void:
	var pause_menu = chain.reference_object

	if not is_instance_valid(seed_label):
		seed_label = Label.new()
		seed_label.name = "SeedLabel"
		seed_label.text = "Seed: %s" % str(RandomService.base_seed)
		seed_label.position = Vector2(20, 20)

		var version_label = pause_menu.get_node("%VersionLabel")
		seed_label.label_settings = version_label.label_settings.duplicate()
		seed_label.position = version_label.position - Vector2(0, 25)

		pause_menu.add_child(seed_label)

	chain.execute_next()
