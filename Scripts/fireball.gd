extends Area2D

var travelled_distance = 0
var speed = 1000
var max_range = 1200
var damage = 10
var pierce_count = 0
var current_pierce = 0
var chain_count = 0
var explosion_radius = 0
var hit_enemies = []

func _ready():
	print("Projectile spawned at: ", global_position)

func _physics_process(delta):
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * speed * delta
	
	travelled_distance += speed * delta
	
	if travelled_distance > max_range:
		queue_free()

func setup_from_skill(skill: SkillBase):
	speed = skill.current_speed
	max_range = skill.current_range
	damage = skill.current_damage
	
	print("Projectile setup - Damage: ", damage, " Speed: ", speed, " Range: ", max_range)

func setup_chain(count: int):
	chain_count = count

func setup_explosion(radius: float):
	explosion_radius = radius

func setup_pierce(count: int):
	pierce_count = count

func _on_body_entered(body):
	if not body.has_method("take_damage"):
		return
		
	# Skip if we've already hit this enemy (for pierce)
	if body in hit_enemies:
		return
		
	hit_enemies.append(body)
	body.take_damage(damage)
	
	# Handle explosion - use call_deferred to avoid tree modification during physics
	if explosion_radius > 0:
		call_deferred("create_explosion")
	
	# Handle pierce
	if current_pierce < pierce_count:
		current_pierce += 1
		return  # Don't destroy projectile yet
	
	# Handle chain
	if chain_count > 0:
		call_deferred("create_chain")
	
	queue_free()

func create_explosion():
	var explosion_area = Area2D.new()
	var collision_shape = CollisionShape2D.new()
	var circle_shape = CircleShape2D.new()
	
	circle_shape.radius = explosion_radius
	collision_shape.shape = circle_shape
	explosion_area.add_child(collision_shape)
	
	get_parent().add_child(explosion_area)
	explosion_area.global_position = global_position
	
	# Find enemies in explosion radius
	await get_tree().process_frame  # Wait for physics update
	var bodies_in_explosion = explosion_area.get_overlapping_bodies()
	
	for body in bodies_in_explosion:
		if body.has_method("take_damage") and body not in hit_enemies:
			body.take_damage(damage * 0.5)  # Explosion does 50% damage
	
	explosion_area.queue_free()
	
	# Create visual effect
	const SMOKE_SCENE = preload("res://Scenes/smoke_explosion.tscn")
	var smoke = SMOKE_SCENE.instantiate()
	get_parent().add_child(smoke)
	smoke.global_position = global_position

func create_chain():
	var enemies = get_tree().get_nodes_in_group("enemies")
	var valid_targets = []
	
	# Find enemies not yet hit and within chain range
	for enemy in enemies:
		if enemy not in hit_enemies:
			var distance = global_position.distance_to(enemy.global_position)
			if distance <= max_range * 0.3:  # Chain range is 30% of base range
				valid_targets.append(enemy)
	
	if valid_targets.size() > 0:
		# Sort by distance and pick closest
		valid_targets.sort_custom(func(a, b): 
			return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position)
		)
		
		var target = valid_targets[0]
		
		# Create new projectile for chain
		var chain_projectile = duplicate()
		get_parent().add_child(chain_projectile)
		chain_projectile.global_position = global_position
		chain_projectile.look_at(target.global_position)
		chain_projectile.chain_count = chain_count - 1
		chain_projectile.damage *= 0.8  # Chain damage reduction
		chain_projectile.hit_enemies = hit_enemies.duplicate()  # Carry forward hit list
		
func setup_target(target_position: Vector2):
	#print("Projectile targeting: ", target_position)
	#print("Projectile current position: ", global_position)
	
	# Aim the projectile at the target
	look_at(target_position)
	
	#print("Projectile aimed at target")
