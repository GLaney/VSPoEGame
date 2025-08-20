extends Area2D

var damage = 10
var explosion_radius = 0
var minion_scene: PackedScene
var chain_count = 0
var hit_enemies = []

func _ready():
	print("Melee attack _ready() called")
	
	# All sprite creation code removed - using scene-based sprite instead
	
	print("Signal connected to existing collision shape")
	
	# Auto-destroy after animation
	var timer = Timer.new()
	timer.wait_time = 1.0  # Attack lasts 1 second for testing
	timer.one_shot = true
	timer.timeout.connect(queue_free)
	add_child(timer)
	timer.start()
	print("Timer started - attack will last 1.0 seconds")

func setup_from_skill(skill: SkillBase):
	damage = skill.current_damage
	
	# Load the skill's unique visual effect
	if skill.visual_effect:
		var visual = skill.visual_effect.instantiate()
		add_child(visual)
		print("Loaded unique visual for skill: ", skill.skill_name)
		
		# If it's an animated sprite, play the animation
		if visual.has_method("play"):
			visual.play()

func setup_explosion(radius: float):
	explosion_radius = radius

func setup_minion_spawn(scene: PackedScene):
	minion_scene = scene

func setup_chain_reaction(count: int):
	chain_count = count

func _on_body_entered(body):
	if not body.has_method("take_damage"):
		return
		
	if body in hit_enemies:
		return
		
	hit_enemies.append(body)
	body.take_damage(damage)
	
	# Handle explosion
	if explosion_radius > 0:
		create_explosion()
	
	# Handle minion spawn
	if minion_scene:
		spawn_minion_at_target(body)
	
	# Handle chain reaction
	if chain_count > 0:
		create_chain_reaction()

func create_explosion():
	# Similar to bullet explosion but for melee
	var explosion_area = Area2D.new()
	var collision_shape = CollisionShape2D.new()
	var circle_shape = CircleShape2D.new()
	
	circle_shape.radius = explosion_radius
	collision_shape.shape = circle_shape
	explosion_area.add_child(collision_shape)
	
	get_parent().add_child(explosion_area)
	explosion_area.global_position = global_position
	
	await get_tree().process_frame
	var bodies_in_explosion = explosion_area.get_overlapping_bodies()
	
	for body in bodies_in_explosion:
		if body.has_method("take_damage") and body not in hit_enemies:
			body.take_damage(damage * 0.7)
	
	explosion_area.queue_free()

func spawn_minion_at_target(target_body):
	if minion_scene:
		var minion = minion_scene.instantiate()
		get_parent().add_child(minion)
		minion.global_position = target_body.global_position

func create_chain_reaction():
	# Create additional melee attacks at nearby enemies
	var enemies = get_tree().get_nodes_in_group("enemies")
	var valid_targets = []
	
	for enemy in enemies:
		if enemy not in hit_enemies:
			var distance = global_position.distance_to(enemy.global_position)
			if distance <= 150:  # Chain range for melee
				valid_targets.append(enemy)
	
	var chains_to_create = min(chain_count, valid_targets.size())
	for i in range(chains_to_create):
		var target = valid_targets[i]
		var chain_attack = duplicate()
		get_parent().add_child(chain_attack)
		chain_attack.global_position = target.global_position
		chain_attack.damage *= 0.8
		chain_attack.chain_count = 0  # Prevent infinite chains
		chain_attack.hit_enemies = hit_enemies.duplicate()
		
func setup_target_direction(target_position: Vector2):
	print("Setting up attack direction toward: ", target_position)
	
	# Calculate direction from player to target
	var direction = global_position.direction_to(target_position)
	var angle = direction.angle()
	
	# Rotate the entire attack toward target
	rotation = angle
	print("Attack rotated to angle: ", rad_to_deg(angle), " degrees")
	
	# Optional: Position the attack in the direction of the target
	position = direction * 200  # 50 units toward the target
