class_name Hitbox
extends Area2D

signal hit_landed(target: Hurtbox)

@export var damage := 1.0
@export var knockback_force := 220.0
@export var start_active := false
@export var rehit_interval := 0.0   # above 0: keep damaging targets that stay inside

var source: Node = null
var _already_hit: Array[Hurtbox] = []
var _rehit_timer := 0.0

func _ready() -> void:
	monitoring = start_active
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	if rehit_interval <= 0.0 or not monitoring:
		return
	_rehit_timer += delta
	if _rehit_timer >= rehit_interval:
		_rehit_timer = 0.0
		_already_hit.clear()
		for a in get_overlapping_areas():
			_on_area_entered(a)

func activate() -> void:
	_already_hit.clear()
	set_deferred("monitoring", true)

func deactivate() -> void:
	set_deferred("monitoring", false)

func _on_area_entered(area: Area2D) -> void:
	var target := area as Hurtbox
	if target == null or _already_hit.has(target):
		return
	_already_hit.append(target)
	var dir := signf(target.global_position.x - global_position.x)
	if dir == 0.0:
		dir = 1.0
	var info := DamageInfo.new()
	info.amount = damage
	info.knockback = Vector2(dir, -0.4).normalized() * knockback_force
	info.source = source
	target.receive_hit(info)
	hit_landed.emit(target)
