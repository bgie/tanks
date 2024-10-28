class_name PlayerStats
extends HBoxContainer

@export var ammo := 99:
	get:
		return ammo
	set(v):
		ammo = v
		$AmmoContainer/AmmoLabel.text = str(clamp(v, 0, 99))

@export var armor := 9:
	get:
		return armor
	set(v):
		armor = v
		$ArmorContainer/ArmorLabel.text = str(clamp(v, 0, 9))

func update_ammo_animated(new_value: int) -> void:
	ammo = new_value
	$AmmoContainer/AnimationPlayer.play("fired")

func update_armor_animated(new_value: int) -> void:
	armor = new_value
	$ArmorContainer/AnimationPlayer.play("hit")
