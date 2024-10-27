extends Node2D

@onready var camera: Camera2D = $Camera2D
@onready var tank_1: RigidBody2D = $Units/Tank1
@onready var tank_2: RigidBody2D = $Units/Tank2

const BORDER_SIZE := 400

func _process(_delta: float) -> void:
	camera.position = (tank_1.position + tank_2.position) * 0.5
	var zoom = get_viewport().size.x / (abs(tank_1.position.x - tank_2.position.x) + 2 * BORDER_SIZE)
	zoom = min(zoom, 0.75)
	camera.zoom = Vector2(zoom, zoom)
