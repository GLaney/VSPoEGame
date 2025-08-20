extends Node
class_name SkillManager

var active_skills: Array[SkillBase] = []
var skill_executors: Array[SkillExecutor] = []

signal skill_acquired(skill: SkillBase)
signal augment_acquired(augment: AugmentBase)

func _ready():
	print("SkillManager _ready() started")
	
	# Load skill from resource file
	var starting_skill = load("res://resources/skills/fireball_skill.tres")
	
	if starting_skill and starting_skill.get_script():
		print("Successfully loaded skill: ", starting_skill.skill_name)
		add_skill(starting_skill)
	else:
		print("Failed to load starting skill!")

func add_skill(skill: SkillBase):
	if active_skills.size() < 4:  # Max 4 active skills
		active_skills.append(skill)
		
		# Create unified executor for this skill
		var executor = SkillExecutor.new(skill)
		add_child(executor)
		skill_executors.append(executor)
		skill_acquired.emit(skill)
		print("Added skill: ", skill.skill_name, " with tags: ", skill.tags)

func add_augment_to_skill(skill_index: int, augment: AugmentBase):
	if skill_index < active_skills.size():
		var success = active_skills[skill_index].add_augment(augment)
		if success:
			# Update the corresponding executor
			skill_executors[skill_index].on_skill_modified()
			augment_acquired.emit(augment)
			print("Added augment: ", augment.augment_name, " to skill: ", active_skills[skill_index].skill_name)
			return true
		else:
			print("Failed to add augment: ", augment.augment_name)
			return false
	return false
