extends Node2D

@onready var camera: Camera2D = $Camera2D
@onready var tank_1: RigidBody2D = $Units/Tank1
@onready var tank_2: RigidBody2D = $Units/Tank2

@onready var player_1_container: VBoxContainer = $CanvasLayer/MarginContainer/Player1Container
@onready var player_1_stats: PlayerStats = $CanvasLayer/MarginContainer/Player1Container/PlayerStats
@onready var player_2_container: VBoxContainer = $CanvasLayer/MarginContainer/Player2Container
@onready var player_2_stats: PlayerStats = $CanvasLayer/MarginContainer/Player2Container/PlayerStats

@onready var win_overlay: ColorRect = $CanvasLayer/WinOverlay
@onready var win_label: Label = $CanvasLayer/WinOverlay/WinLabel
@onready var win_message_timer: Timer = $CanvasLayer/WinOverlay/WinMessageTimer
@onready var restart_timer: Timer = $CanvasLayer/WinOverlay/RestartTimer

var active_players := 2

const BORDER_SIZE := 400

func _ready() -> void:
	player_1_stats.ammo = tank_1.ammo
	player_1_stats.armor = tank_1.armor
	player_2_stats.ammo = tank_2.ammo
	player_2_stats.armor = tank_2.armor

func _process(_delta: float) -> void:
	if active_players == 2:
		camera.position = (tank_1.position + tank_2.position) * 0.5
		var zoom = get_viewport().size.x / (abs(tank_1.position.x - tank_2.position.x) + 2 * BORDER_SIZE)
		zoom = min(zoom, 0.75)
		camera.zoom = Vector2(zoom, zoom)


func _on_tank_1_died() -> void:
	tank_1 = null
	player_1_container.queue_free()
	player_1_container = null
	active_players -= 1
	if win_message_timer.is_stopped():
		win_message_timer.start()

func _on_tank_2_died() -> void:
	tank_2 = null
	player_2_container.queue_free()
	player_2_container = null
	active_players -= 1
	if win_message_timer.is_stopped():
		win_message_timer.start()


func _on_win_message_timer_timeout() -> void:
	if active_players == 0:
		win_label.text = "Nobody\nwins!"
	elif tank_1 != null:
		win_label.text = "Player 1\nwins!"
	elif tank_2 != null:
		win_label.text = "Player 2\nwins!"
	else:
		win_label.text = "Everybody\nwins!" # this should not happen
	win_overlay.visible = true
	restart_timer.start()

func _on_restart_timer_timeout() -> void:
	get_tree().reload_current_scene()
