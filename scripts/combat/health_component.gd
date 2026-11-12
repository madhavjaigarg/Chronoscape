class_name HealthComponent
extends Node

signal health_changed(current: float, maximum: float)
signal damaged(info: DamageInfo)
signal died

@export var max_health := 10.0
@export var invincibility_time := 0.0

var current: float
var _inv_timer := 0.0

func _ready() -> void:
	current = max_health

func _process(delta: float) -> void:
	if _inv_timer > 0.0:
		_inv_timer -= delta

func is_invincible() -> bool:
	return _inv_timer > 0.0

func grant_invincibility(seconds: float) -> void:
	_inv_timer = maxf(_inv_timer, seconds)

func take_damage(info: DamageInfo) -> void:
	if current <= 0.0 or is_invincible():
		return
	current = maxf(current - info.amount, 0.0)
	health_changed.emit(current, max_health)
	damaged.emit(info)
	if current <= 0.0:
		died.emit()
	else:
		grant_invincibility(invincibility_time)

func heal(amount: float) -> void:
	current = minf(current + amount, max_health)
	health_changed.emit(current, max_health)
