extends Node
class_name SkillExecutor

var skill: SkillBase
var cooldown_timer: Timer
var player: CharacterBody2D

func _init(skill_data: SkillBase):
	skill = skill_data
	
	# Force reset stats to ensure they're correct
	skill.reset_to_base_stats()
	print("Forced reset - Current damage: ", skill.current_damage, " Current speed: ", skill.current_speed)
	
func _ready():
	player = get_node("/root/Game/Player")
	
	print("Setting up timer with cooldown: ", skill.current_cooldown, " (base: ", skill.base_cooldown, ")")
	
	# Setup cooldown timer
	cooldown_timer = Timer.new()
	cooldown_timer.wait_time = skill.current_cooldown
	cooldown_timer.timeout.connect(_on_cooldown_timeout)
	add_child(cooldown_timer)
	cooldown_timer.start()
	print("SkillExecutor ready for: ", skill.skill_name)

func _on_cooldown_timeout():
	execute_skill()
	cooldown_timer.wait_time = skill.current_cooldown
	cooldown_timer.start()

func execute_skill():
	var target = get_nearest_enemy()
	if not target:
		print("No target found for ", skill.skill_name)
		return
		
	var distance_to_target = player.global_position.distance_to(target.global_position)
	if distance_to_target > skill.current_range:
		print("Target too far for ", skill.skill_name, " (", distance_to_target, " > ", skill.current_range, ")")
		return
		
	print("Executing skill: ", skill.skill_name, " | Cooldown: ", skill.current_cooldown)
	print("Execution scene: ", skill.execution_scene)
	
	# Create the skill's execution scene
	if skill.execution_scene:
		print("Creating skill instance...")
		var skill_instance = skill.execution_scene.instantiate()
		print("Skill instance created: ", skill_instance)
		
		player.get_parent().add_child(skill_instance)
		
		# Set position to player location
		skill_instance.global_position = player.global_position
		print("Set skill instance position to: ", skill_instance.global_position)
		
		print("Skill instance added to scene")
		
		# Setup the skill instance with data and target
		if skill_instance.has_method("setup_from_skill"):
			print("About to call setup_from_skill with skill: ", skill.skill_name)
			print("Skill current_damage before setup: ", skill.current_damage)
			skill_instance.setup_from_skill(skill)
		else:
			print("Skill instance doesn't have setup_from_skill method")
		
		if skill_instance.has_method("setup_target"):
			print("Calling setup_target...")
			skill_instance.setup_target(target.global_position)
		else:
			print("Skill instance doesn't have setup_target method")
		
		# Apply augment behaviors based on tags
		apply_augment_behaviors(skill_instance)
	else:
		print("ERROR: No execution scene set for skill!")

func apply_augment_behaviors(skill_instance):
	for augment in skill.augments:
		# Apply behaviors that the skill instance supports
		if augment.adds_chain and skill_instance.has_method("setup_chain"):
			skill_instance.setup_chain(augment.chain_count)
		if augment.adds_explosion and skill_instance.has_method("setup_explosion"):
			skill_instance.setup_explosion(augment.explosion_radius)
		if augment.adds_pierce and skill_instance.has_method("setup_pierce"):
			skill_instance.setup_pierce(augment.pierce_count)

func on_skill_modified():
	cooldown_timer.wait_time = skill.current_cooldown

func get_nearest_enemy() -> CharacterBody2D:
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return null
		
	var nearest_enemy = null
	var shortest_distance = INF
	
	for enemy in enemies:
		var distance = player.global_position.distance_to(enemy.global_position)
		if distance < shortest_distance:
			shortest_distance = distance
			nearest_enemy = enemy
			
	return nearest_enemy
