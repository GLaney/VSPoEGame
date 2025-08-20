extends Resource
class_name SkillBase

@export var skill_name: String
@export var base_damage: float = 10.0
@export var base_cooldown: float = 1.0
@export var base_range: float = 1200.0
@export var base_speed: float = 1000.0

# NEW: Tag-based system
@export var tags: Array[String] = []  # e.g. ["projectile", "fire", "spell"]
@export var execution_scene: PackedScene  # What happens when skill fires

# These will be modified by augments
var current_damage: float
var current_cooldown: float
var current_range: float
var current_speed: float
var augments: Array[AugmentBase] = []

func _init():
	reset_to_base_stats()
	print("SkillBase initialized - current_cooldown: ", current_cooldown)

func reset_to_base_stats():
	current_damage = base_damage
	current_cooldown = base_cooldown
	current_range = base_range
	current_speed = base_speed

func has_tag(tag: String) -> bool:
	return tag in tags

func has_any_tag(check_tags: Array[String]) -> bool:
	for tag in check_tags:
		if has_tag(tag):
			return true
	return false

func has_all_tags(check_tags: Array[String]) -> bool:
	for tag in check_tags:
		if not has_tag(tag):
			return false
	return true

func can_add_augment(augment: AugmentBase) -> bool:
	# Check if we already have this augment
	for existing_augment in augments:
		if existing_augment.augment_name == augment.augment_name:
			return false
	
	# Check if we're at max augments
	if augments.size() >= 4:
		return false
	
	# Check tag compatibility
	if not augment.is_compatible_with_skill(self):
		return false
	
	return true

func add_augment(augment: AugmentBase) -> bool:
	if can_add_augment(augment):
		augments.append(augment)
		apply_augment(augment)
		return true
	return false

func apply_augment(augment: AugmentBase):
	# Apply stat modifications
	current_damage *= augment.damage_multiplier
	current_damage += augment.damage_flat
	current_cooldown *= augment.cooldown_multiplier
	current_speed *= augment.speed_multiplier
	current_range *= augment.range_multiplier

func remove_augment(augment: AugmentBase):
	augments.erase(augment)
	recalculate_stats()

func recalculate_stats():
	reset_to_base_stats()
	for augment in augments:
		apply_augment(augment)
