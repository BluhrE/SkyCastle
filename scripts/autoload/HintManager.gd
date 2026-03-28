extends Node


func get_hint(scene_id: String) -> String:
	match scene_id:
		"castle_intro":
			return "Listen for the sparkle clue, then click the glowing tower door."
		"map_room":
			for world_id in WorldLibrary.get_world_ids():
				if GameState.is_world_unlocked(world_id) and not GameState.is_world_completed(world_id):
					var world: Dictionary = WorldLibrary.get_world(world_id)
					return "%s is glowing. Click it to travel with Sky." % String(world.get("name", "The next world"))
			if GameState.save_data.get("celebration_ready", false):
				return "All five ribbons are shining. The Sunset Rainbow Celebration can come next."
			if GameState.is_world_completed("waterfall"):
				return "The map is brighter now. Look for the next glowing chapter."
			return "The map is still sleepy. Follow the story first."
		"waterfall":
			if GameState.is_world_completed("waterfall"):
				return "Bibi is happy now. You can look around or return to the map."
			if QuestManager.are_core_tasks_complete():
				return "The crystal ledge is sparkling. Drag the crystal into place to restore the song."
			var next_task := QuestManager.get_first_incomplete_task_name()
			if next_task.is_empty():
				return "Click something bright to help Bibi."
			return "Try the next glowing helper spot: %s." % next_task
		"forest":
			if GameState.is_world_completed("forest"):
				return "The forest echoes are happy again. You can revisit Hazel or head back to the map."
			return "Help each glowing forest spot, then finish the bright echo lantern."
		"beach":
			if GameState.is_world_completed("beach"):
				return "The beach tides are sparkling again. You can revisit Tilly or head back to the map."
			return "Follow the glowing beach spots and finish the sunshine sail at the end."
		"zoo":
			if GameState.is_world_completed("zoo"):
				return "The zoo friends are cheerful again. You can revisit Nora or return to the map."
			return "Try each happy animal helper spot, then open the parade gate."
		"house":
			if GameState.is_world_completed("house"):
				return "Mimi's secret surprise is ready. You can revisit the house or head back to the map."
			return "Help with the glowing house jobs, then place the surprise bow last."
		_:
			return "Sparkly places often hide the next gentle step."
