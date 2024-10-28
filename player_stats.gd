@tool
extends HBoxContainer

@export var ammo := 999:
	get:
		return ammo
	set(v):
		ammo = v
		$AmmoContainer/AmmoLabel.text = str(clamp(v, 0, 999))

@export var armor := 99:
	get:
		return armor
	set(v):
		armor = v
		$ArmorContainer/ArmorLabel.text = str(clamp(v, 0, 99))
