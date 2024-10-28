extends Node2D

@onready var camera: Camera2D = $Camera2D
@onready var tank_1: RigidBody2D = $Units/Tank1
@onready var tank_2: RigidBody2D = $Units/Tank2

@onready var player_1_container: VBoxContainer = $CanvasLayer/MarginContainer/Player1Container
@onready var player_1_stats: PlayerStats = $CanvasLayer/MarginContainer/Player1Container/PlayerStats
@onready var player_2_container: VBoxContainer = $CanvasLayer/MarginContainer/Player2Container
@onready var player_2_stats: PlayerStats = $CanvasLayer/MarginContainer/Player2Container/PlayerStats

@onready var win_overlay: Control = $CanvasLayer/WinOverlay
@onready var win_label: Label = $CanvasLayer/WinOverlay/WinLabel
@onready var win_message_timer: Timer = $CanvasLayer/WinOverlay/WinMessageTimer
@onready var restart_timer: Timer = $CanvasLayer/WinOverlay/RestartTimer

var active_players := 2
var camera_initial_offset : Vector2
var shaking := false

const MIN_CAMERA_ZOOM := 1.0
const CAMERA_SHAKE_MAGNITUDE := 20.0
const CAMERA_ROTATE_MAGNITUDE := 2.0
const BORDER_SIZE := 400
const PLAYER_WINS_CAMERA_OFFSET := Vector2(0, -200)

func _ready() -> void:
	camera_initial_offset = camera.offset
	player_1_stats.ammo = tank_1.ammo
	player_1_stats.armor = tank_1.armor
	player_2_stats.ammo = tank_2.ammo
	player_2_stats.armor = tank_2.armor

func _process(delta: float) -> void:
	if Explosion.camera_shake_amount > 0:
		var shake := Vector2( 
			randf_range(-CAMERA_SHAKE_MAGNITUDE, CAMERA_SHAKE_MAGNITUDE) * Explosion.camera_shake_amount,
			randf_range(-CAMERA_SHAKE_MAGNITUDE, CAMERA_SHAKE_MAGNITUDE) * Explosion.camera_shake_amount)
		camera.offset = camera_initial_offset + shake
		Explosion.camera_shake_amount = clamp(Explosion.camera_shake_amount - delta, 0.0, Explosion.MAXIMUM_TOTAL_EXPLOSION_SHAKE)
		shaking = true
	elif shaking:
		camera.offset = camera_initial_offset
		shaking = false
	
	if active_players == 2:
		camera.position = (tank_1.position + tank_2.position) * 0.5
		var zoom = get_viewport().size.x / (abs(tank_1.position.x - tank_2.position.x) + 2 * BORDER_SIZE)
		zoom = min(zoom, MIN_CAMERA_ZOOM)
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
		var tween := create_tween()
		tween.tween_property(camera, "position", tank_1.position + PLAYER_WINS_CAMERA_OFFSET, 1.5)
		tween.parallel().tween_property(camera, "zoom", Vector2(MIN_CAMERA_ZOOM, MIN_CAMERA_ZOOM), 1.5)
		win_label.text = "Player 1\nwins!"
	elif tank_2 != null:
		var tween := create_tween()
		tween.tween_property(camera, "position", tank_2.position + PLAYER_WINS_CAMERA_OFFSET, 1.5)
		tween.parallel().tween_property(camera, "zoom", Vector2(MIN_CAMERA_ZOOM, MIN_CAMERA_ZOOM), 1.5)
		win_label.text = "Player 2\nwins!"
	else:
		win_label.text = "Everybody\nwins!" # this should not happen
	win_overlay.modulate = Color(1,1,1,0)
	create_tween().tween_property(win_overlay, "modulate:a", 1.0, 1.5)
	win_overlay.visible = true
	restart_timer.start()

func _on_restart_timer_timeout() -> void:
	get_tree().reload_current_scene()
