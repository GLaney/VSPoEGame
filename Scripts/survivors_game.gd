extends Node2D

func _ready():
	# Your existing code...
	
	# Add debug menu to a CanvasLayer so it stays on screen
	print("Adding debug menu...")
	var canvas_layer = CanvasLayer.new()
	add_child(canvas_layer)
	
	var debug_menu = preload("res://scenes/debug_skill_menu.tscn").instantiate()
	canvas_layer.add_child(debug_menu)
	print("Debug menu added to canvas layer")

func spawn_mob():
	var new_mob = preload("res://Scenes/mob.tscn").instantiate()
	%PathFollow2D.progress_ratio = randf()
	new_mob.global_position = %PathFollow2D.global_position
	add_child(new_mob)


func _on_timer_timeout():
	spawn_mob()


func _on_player_health_depleted() -> void:
	%GameOver.visible = true
	get_tree().paused = true
