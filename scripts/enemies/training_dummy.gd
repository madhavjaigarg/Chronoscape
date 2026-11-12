extends CharacterBody2D

@onready var health: HealthComponent = $HealthComponent
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var sprite: Sprite2D = $Sprite2D

var _gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	hurtbox.health = health
	health.damaged.connect(_on_damaged)
	health.died.connect(_on_died)

func _on_damaged(info: DamageInfo) -> void:
	velocity += info.knockback
	sprite.modulate = Color.RED
	create_tween().tween_property(sprite, "modulate", Color.WHITE, 0.15)

func _on_died() -> void:
	print("Dummy died")
	health.heal(health.max_health)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += _gravity * delta
	velocity.x = move_toward(velocity.x, 0.0, 800.0 * delta)
	move_and_slide()
