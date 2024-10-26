extends Node2D

@onready var camera: Camera2D = $Camera2D
@onready var tank_1: RigidBody2D = $Tank1


func _process(_delta: float) -> void:
	camera.position = tank_1.position
