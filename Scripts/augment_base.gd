extends Resource
class_name AugmentBase

@export var augment_name: String
@export var description: String

# Tag requirements - determines which skills this can support
@export var required_tags: Array[String] = []  # Must have at least one of these
@export var forbidden_tags: Array[String] = []  # Cannot have any of these
@export var requires_all_tags: Array[String] = []  # Must have ALL of these

# Stat modifiers
@export var damage_multiplier: float = 1.0
@export var damage_flat: float = 0.0
@export var cooldown_multiplier: float = 1.0
@export var speed_multiplier: float = 1.0
@export var range_multiplier: float = 1.0

# Behavioral modifiers
@export var adds_chain: bool = false
@export var chain_count: int = 0
@export var adds_explosion: bool = false
@export var explosion_radius: float = 0.0
@export var adds_pierce: bool = false
@export var pierce_count: int = 0
@export var spawns_minion_on_hit: bool = false
@export var minion_scene: PackedScene

func is_compatible_with_skill(skill: SkillBase) -> bool:
	# Check forbidden tags
	for forbidden_tag in forbidden_tags:
		if skill.has_tag(forbidden_tag):
			print("Augment ", augment_name, " forbidden due to tag: ", forbidden_tag)
			return false
	
	# Check required tags (must have at least one)
	if required_tags.size() > 0:
		if not skill.has_any_tag(required_tags):
			print("Augment ", augment_name, " requires one of: ", required_tags)
			return false
	
	# Check requires_all_tags (must have every single one)
	if requires_all_tags.size() > 0:
		if not skill.has_all_tags(requires_all_tags):
			print("Augment ", augment_name, " requires all of: ", requires_all_tags)
			return false
	
	return true
