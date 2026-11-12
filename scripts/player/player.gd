class_name Player
extends CharacterBody2D

@export var max_speed := 220.0
@export var acceleration := 1600.0
@export var friction := 2000.0
@export var jump_velocity := -420.0
@export var gravity_scale := 1.0
@export var coyote_time := 0.1
@export var jump_buffer_time := 0.12
@export var attack_duration := 0.15
@export var attack_cooldown_time := 0.3
@export var hurt_stun_time := 0.2
@export var hurt_invincibility := 0.6

@onready var visuals: Node2D = $Visuals
@onready var body_sprite: Sprite2D = $Visuals/Body
@onready var melee_hitbox: Hitbox = $Visuals/MeleeHitbox
@onready var melee_flash: ColorRect = $Visuals/MeleeHitbox/Flash
@onready var health: HealthComponent = $HealthComponent
@onready var hurtbox: Hurtbox = $HurtBox

var facing := 1
var _coyote := 0.0
var _jump_buffer := 0.0
var _attack_timer := 0.0
var _attack_cooldown := 0.0
var _hurt_timer := 0.0
var _gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	add_to_group(&"player")
	hurtbox.health = health
	melee_hitbox.source = self
	melee_flash.visible = false
	health.invincibility_time = hurt_invincibility
	health.damaged.connect(_on_damaged)
	health.died.connect(_on_died)

func _physics_process(delta: float) -> void:
	_tick_timers(delta)

	if is_on_floor():
		_coyote = coyote_time
	else:
		_coyote = maxf(_coyote - delta, 0.0)
		velocity.y += _gravity * gravity_scale * delta

	var stunned := _hurt_timer > 0.0
	var dir := 0.0 if stunned else Input.get_axis("move_left", "move_right")

	if dir != 0.0:
		facing = 1 if dir > 0.0 else -1
		visuals.scale.x = facing

	if not stunned:
		_handle_jump()
		_handle_attack()

	if stunned:
		velocity.x = move_toward(velocity.x, 0.0, friction * 0.25 * delta)
	elif dir != 0.0:
		velocity.x = move_toward(velocity.x, dir * max_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)

	move_and_slide()

func _tick_timers(delta: float) -> void:
	_jump_buffer = maxf(_jump_buffer - delta, 0.0)
	_attack_cooldown = maxf(_attack_cooldown - delta, 0.0)
	_hurt_timer = maxf(_hurt_timer - delta, 0.0)
	if _attack_timer > 0.0:
		_attack_timer -= delta
		if _attack_timer <= 0.0:
			_end_attack()

func _handle_jump() -> void:
	if Input.is_action_just_pressed("jump"):
		_jump_buffer = jump_buffer_time
	if _jump_buffer > 0.0 and _coyote > 0.0:
		velocity.y = jump_velocity
		_jump_buffer = 0.0
		_coyote = 0.0
	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= 0.5

func _handle_attack() -> void:
	if Input.is_action_just_pressed("attack_primary") and _attack_cooldown <= 0.0 and _attack_timer <= 0.0:
		_attack_timer = attack_duration
		_attack_cooldown = attack_cooldown_time
		melee_hitbox.activate()
		melee_flash.visible = true

func _end_attack() -> void:
	melee_hitbox.deactivate()
	melee_flash.visible = false

func _on_damaged(info: DamageInfo) -> void:
	_hurt_timer = hurt_stun_time
	velocity = info.knockback
	if _attack_timer > 0.0:
		_attack_timer = 0.0
		_end_attack()
	body_sprite.modulate = Color.RED
	create_tween().tween_property(body_sprite, "modulate", Color.WHITE, 0.2)

func _on_died() -> void:
	print("Player died (Temporal Rewind goes here later)")
	health.heal(health.max_health)
