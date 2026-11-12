class_name Hurtbox
extends Area2D

signal hit(info: DamageInfo)

@export var health: HealthComponent

func receive_hit(info: DamageInfo) -> void:
	hit.emit(info)
	if health:
		health.take_damage(info)
