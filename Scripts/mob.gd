extends CharacterBody2D

var health = 30  # Increased health to better test damage system
@onready var player = get_node("/root/Game/Player")

func _ready():
	%Slime.play_walk()
	add_to_group("enemies")  # Important for targeting system

func _physics_process(delta):
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * 300
	move_and_slide()

func take_damage(damage_amount: float = 10):
	health -= damage_amount
	%Slime.play_hurt()
	
	# Show damage number (optional visual feedback)
	show_damage_number(damage_amount)
	
	if health <= 0:
		die()

func show_damage_number(damage: float):
	const DAMAGE_NUMBER = preload("res://scenes/damage_number.tscn")
	var damage_label = DAMAGE_NUMBER.instantiate()
	get_parent().add_child(damage_label)
	damage_label.setup(damage, global_position)

func die():
	queue_free()
	const SMOKE_SCENE = preload("res://Scenes/smoke_explosion.tscn")
	var smoke = SMOKE_SCENE.instantiate()
	get_parent().add_child(smoke)
	smoke.global_position = global_position
