extends CharacterBody2D

signal health_depleted

var max_health = 1000000.0
var health = max_health
var skill_manager: SkillManager

func _ready():
	# Initialize skill system
	skill_manager = SkillManager.new()
	add_child(skill_manager)
	
	# Add enemies to group for targeting
	var mobs = get_tree().get_nodes_in_group("enemies")
	for mob in mobs:
		if not mob.is_in_group("enemies"):
			mob.add_to_group("enemies")

func _physics_process(delta):
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * 600
	move_and_slide()
	
	if velocity.length() > 0.0:
		%HappyBoo.play_walk_animation()
	else:
		%HappyBoo.play_idle_animation()
	
	const DAMAGE_RATE = 20.0
	var overlapping_mobs = %HurtBox.get_overlapping_bodies()
	if overlapping_mobs.size() > 0:
		health -= DAMAGE_RATE * overlapping_mobs.size() * delta
		%ProgressBar.value = health
		if health <= 0.0:
			health_depleted.emit()

# For testing - add these functions to test the system
func _input(event):
	if event.is_action_pressed("ui_accept"):  # Spacebar
		test_add_augment()

func test_add_augment():
	# Create a test chain augment
	var chain_augment = AugmentBase.new()
	chain_augment.augment_name = "Chain Lightning"
	chain_augment.adds_chain = true
	chain_augment.chain_count = 2
	chain_augment.damage_multiplier = 1.2
	
	# Add to first skill
	if skill_manager.active_skills.size() > 0:
		skill_manager.add_augment_to_skill(0, chain_augment)
		print("Added chain augment to skill!")
