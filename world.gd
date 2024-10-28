extends Node2D

@onready var camera: Camera2D = $Camera2D
@onready var tank_1: RigidBody2D = $Units/Tank1
@onready var tank_2: RigidBody2D = $Units/Tank2
@onready var player_1_stats: PlayerStats = $CanvasLayer/MarginContainer/Player1Container/PlayerStats
@onready var player_2_stats: PlayerStats = $CanvasLayer/MarginContainer/Player2Container/PlayerStats

const BORDER_SIZE := 400

func _ready() -> void:
	player_1_stats.ammo = tank_1.ammo
	player_1_stats.armor = tank_1.armor
	player_2_stats.ammo = tank_2.ammo
	player_2_stats.armor = tank_2.armor

func _process(_delta: float) -> void:
	camera.position = (tank_1.position + tank_2.position) * 0.5
	var zoom = get_viewport().size.x / (abs(tank_1.position.x - tank_2.position.x) + 2 * BORDER_SIZE)
	zoom = min(zoom, 0.75)
	camera.zoom = Vector2(zoom, zoom)
