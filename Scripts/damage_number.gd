extends Label

func setup(damage_value: float, start_pos: Vector2):
	text = str(int(damage_value))
	add_theme_color_override("font_color", Color.RED)
	global_position = start_pos + Vector2(randf_range(-20, 20), -30)
	
	# Simple, reliable animation
	var tween = create_tween()
	tween.parallel().tween_property(self, "global_position", global_position + Vector2(0, -50), 1.0)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 1.0)
	tween.tween_callback(queue_free)
