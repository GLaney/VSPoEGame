extends Control

var skill_manager: SkillManager
var available_skills: Array[SkillBase] = []
var available_augments: Array[AugmentBase] = []

# UI elements
var skill_container: VBoxContainer
var augment_container: VBoxContainer

func _ready():
	print("DEBUG MENU READY - visible: ", visible)
	
	# Set up the UI
	setup_ui()
	
	# Find the skill manager
	var player = get_node("/root/Game/Player")
	if player:
		skill_manager = player.skill_manager
		load_available_skills_and_augments()
		populate_menu()

func setup_ui():
	# Main container
	var main_container = VBoxContainer.new()
	add_child(main_container)
	
	# Title
	var title = Label.new()
	title.text = "DEBUG SKILL MENU"
	title.add_theme_font_size_override("font_size", 20)
	main_container.add_child(title)
	
	# Skills section
	var skills_label = Label.new()
	skills_label.text = "Active Skills:"
	skills_label.add_theme_font_size_override("font_size", 16)
	main_container.add_child(skills_label)
	
	skill_container = VBoxContainer.new()
	main_container.add_child(skill_container)
	
	# Separator
	var separator = HSeparator.new()
	main_container.add_child(separator)
	
	# Augments section
	var augments_label = Label.new()
	augments_label.text = "Available Augments:"
	augments_label.add_theme_font_size_override("font_size", 16)
	main_container.add_child(augments_label)
	
	augment_container = VBoxContainer.new()
	main_container.add_child(augment_container)
	
	# Position the menu
	position = Vector2(20, 20)
	size = Vector2(400, 600)

func load_available_skills_and_augments():
	# Load available skills
	var fireball_skill = load("res://resources/skills/fireball_skill.tres")
	if fireball_skill:
		available_skills.append(fireball_skill)
		print("Loaded Fireball - tags: ", fireball_skill.tags, " execution_scene: ", fireball_skill.execution_scene)
	
	# Add Ice Bolt skill
	var ice_bolt_skill = load("res://resources/skills/ice_bolt_skill.tres")
	if ice_bolt_skill:
		available_skills.append(ice_bolt_skill)
		print("Loaded Ice Bolt - tags: ", ice_bolt_skill.tags, " execution_scene: ", ice_bolt_skill.execution_scene)
		print("Ice Bolt damage: ", ice_bolt_skill.base_damage, " speed: ", ice_bolt_skill.base_speed)
	else:
		print("ERROR: Failed to load Ice Bolt skill - check if ice_bolt_skill.tres exists")
	
	# Load actual augment resources instead of creating test ones
	load_augment_resources()

func create_test_augments():
	# Chain augment
	var chain_augment = AugmentBase.new()
	chain_augment.augment_name = "Added Chains"
	chain_augment.required_tags.append("projectile")  # Use append instead of assignment
	chain_augment.adds_chain = true
	chain_augment.chain_count = 2
	chain_augment.damage_multiplier = 1.2
	available_augments.append(chain_augment)
	
	# Pierce augment
	var pierce_augment = AugmentBase.new()
	pierce_augment.augment_name = "Projectile Pierce"
	pierce_augment.required_tags.append("projectile")
	pierce_augment.forbidden_tags.append("chaining")  # Use append instead of assignment
	pierce_augment.adds_pierce = true
	pierce_augment.pierce_count = 3
	pierce_augment.damage_multiplier = 1.1
	available_augments.append(pierce_augment)
	
	# Fire explosion augment
	var explosion_augment = AugmentBase.new()
	explosion_augment.augment_name = "Fire Explosion"
	explosion_augment.required_tags.append("fire")
	explosion_augment.adds_explosion = true
	explosion_augment.explosion_radius = 100.0
	explosion_augment.damage_multiplier = 1.3
	available_augments.append(explosion_augment)
	
	# Speed augment
	var speed_augment = AugmentBase.new()
	speed_augment.augment_name = "Faster Projectiles"
	speed_augment.required_tags.append("projectile")
	speed_augment.speed_multiplier = 1.5
	speed_augment.cooldown_multiplier = 0.8
	available_augments.append(speed_augment)

func populate_menu():
	# Clear existing content
	for child in skill_container.get_children():
		child.queue_free()
	for child in augment_container.get_children():
		child.queue_free()
	
	# Add skill checkboxes - only allow one to be selectedaaaaaaa
	for i in range(available_skills.size()):
		var skill = available_skills[i]
		var checkbox = CheckBox.new()
		checkbox.text = skill.skill_name + " " + str(skill.tags)
		
		# Check if this specific skill is the currently active one
		checkbox.button_pressed = (skill_manager.active_skills.size() > 0 and skill_manager.active_skills[0] == skill)
		
		# Connect signal
		var skill_index = i
		checkbox.toggled.connect(_on_skill_toggled.bind(skill_index))
		
		skill_container.add_child(checkbox)
	
	# Add augment buttons (for currently active skills)
	if skill_manager.active_skills.size() > 0:
		var active_skill = skill_manager.active_skills[0]  # Use first active skill
		
		for augment in available_augments:
			var button = Button.new()
			
			# Check if augment is already applied
			var already_has = augment in active_skill.augments
			var can_add = active_skill.can_add_augment(augment)
			
			if already_has:
				button.text = "✓ " + augment.augment_name + " (click to remove)"
				button.add_theme_color_override("font_color", Color.GREEN)
				button.pressed.connect(_on_augment_removed.bind(augment))
			elif can_add:
				button.text = "+ " + augment.augment_name
				button.add_theme_color_override("font_color", Color.WHITE)
				button.pressed.connect(_on_augment_selected.bind(augment))
			else:
				button.text = "✗ " + augment.augment_name + " (incompatible)"
				button.add_theme_color_override("font_color", Color.GRAY)
				button.disabled = true
			
			augment_container.add_child(button)

func _on_skill_toggled(skill_index: int, button_pressed: bool):
	var skill = available_skills[skill_index]
	
	if button_pressed:
		# Clear all current skills first
		skill_manager.active_skills.clear()
		
		# Remove all current skill executors
		for executor in skill_manager.skill_executors:
			executor.queue_free()
		skill_manager.skill_executors.clear()
		
		print("Cleared all active skills")
		
		# Add the new skill
		skill_manager.add_skill(skill)
		print("Replaced with skill: ", skill.skill_name)
	else:
		# If unchecking, remove the skill
		if skill in skill_manager.active_skills:
			var skill_index_in_manager = skill_manager.active_skills.find(skill)
			if skill_index_in_manager >= 0:
				skill_manager.active_skills.remove_at(skill_index_in_manager)
				skill_manager.skill_executors[skill_index_in_manager].queue_free()
				skill_manager.skill_executors.remove_at(skill_index_in_manager)
				print("Removed skill: ", skill.skill_name)
	
	# Refresh the menu to update checkboxes and augments
	populate_menu()

func _on_augment_selected(augment: AugmentBase):
	if skill_manager.active_skills.size() > 0:
		var success = skill_manager.add_augment_to_skill(0, augment)
		if success:
			print("Added augment: ", augment.augment_name)
			populate_menu()  # Refresh the menu
		else:
			print("Failed to add augment: ", augment.augment_name)

# Toggle menu visibility
func _input(event):
	#print("Debug menu received input: ", event)
	if event.is_action_pressed("ui_cancel"):  # ESC key
		#print("ESC pressed - toggling visibility from ", visible, " to ", !visible)
		visible = !visible
		
func _on_augment_removed(augment: AugmentBase):
	if skill_manager.active_skills.size() > 0:
		var active_skill = skill_manager.active_skills[0]
		active_skill.remove_augment(augment)
		
		# Update the skill executor
		if skill_manager.skill_executors.size() > 0:
			skill_manager.skill_executors[0].on_skill_modified()
		
		print("Removed augment: ", augment.augment_name)
		populate_menu()  # Refresh the menu
		
func load_augment_resources():
	# Load all your augment files
	var augment_files = [
		"res://resources/augments/chain_augment.tres",
		"res://resources/augments/cold_slow.tres", 
		"res://resources/augments/fire_explosion.tres",
		"res://resources/augments/melee_reach.tres",
		"res://resources/augments/physical_bleed.tres",
		"res://resources/augments/projectile_pierce.tres",
		"res://resources/augments/spell_echo.tres",
		"res://resources/augments/weapon_elemental_damage.tres"
	]
	
	for augment_path in augment_files:
		var augment = load(augment_path)
		if augment:
			available_augments.append(augment)
			print("Loaded augment: ", augment.augment_name, " - requires: ", augment.required_tags)
		else:
			print("Failed to load augment: ", augment_path)
	
	print("Total augments loaded: ", available_augments.size())
