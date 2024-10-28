extends RigidBody2D

@export var drive_left_action := "ui_left"
@export var drive_right_action := "ui_left"
@export var turret_up_action := "ui_up"
@export var turret_down_action := "ui_down"
@export var fire_action := "ui_accept"

@export var turret_min_angle: float = -60.0
@export var turrent_max_angle: float = 0.0

@export var ammo := 30 :
	get:
		return ammo
	set(v):
		ammo = v
		ammo_changed.emit(v)

signal ammo_changed(new_value: int)

@export var armor := 5 :
	get:
		return armor
	set(v):
		armor = v
		armor_changed.emit(v)

signal armor_changed(new_value: int)

const FULL_MOTOR_POWER: float = 40_000
const MIN_MOTOR_POWER: float = 4_000
const MAX_VELOCITY: float = 300

const TURRET_ROTATE_SPEED: float = 50.0
const FIRE_IMPULSE = Vector2(1600, 0)
const RECOIL_EXAGGERATION = 2.5

var bullet_scene = preload("res://bullet.tscn")

@onready var turret: Sprite2D = $Turret
@onready var turret_cooldown_timer: Timer = $Turret/CooldownTimer
@onready var bullet_spawn: Marker2D = $Turret/BulletSpawn

func _physics_process(delta: float) -> void:
	var turret_movement = Input.get_axis(turret_up_action, turret_down_action) * delta * TURRET_ROTATE_SPEED
	turret.rotation_degrees = clamp(turret.rotation_degrees + turret_movement, turret_min_angle, turrent_max_angle)

	if Input.is_action_pressed(fire_action) && turret_cooldown_timer.is_stopped() && ammo > 0:
		ammo -= 1
		turret_cooldown_timer.start()
		var bullet = bullet_scene.instantiate()
		bullet.position = bullet_spawn.global_position
		bullet.rotation = self.rotation + turret.rotation + bullet_spawn.rotation
		var impulse := FIRE_IMPULSE.rotated(bullet.rotation)
		bullet.apply_impulse(impulse)
		self.apply_impulse(-impulse * RECOIL_EXAGGERATION, turret.position)
		get_parent().add_child(bullet)

func _integrate_forces(state: PhysicsDirectBodyState2D):
	var tank_movement: float = Input.get_axis(drive_left_action, drive_right_action)
	if tank_movement == 0:
		self.physics_material_override.friction = 1.0
	else:
		self.physics_material_override.friction = 0.0

		var contact_count = state.get_contact_count()
		for i in contact_count:
			var contact_pos = to_local(state.get_contact_local_position(i))
			if contact_pos.y > 0.0:
				var motor_force_vector := state.get_contact_local_normal(i).rotated(PI/2) * tank_movement
				var local_velocity := state.get_contact_local_velocity_at_position(i)
				var requested_speed_reached := motor_force_vector.dot(local_velocity) / MAX_VELOCITY
				var motor_power = FULL_MOTOR_POWER * (1 - requested_speed_reached)
				motor_power = clamp(motor_power, MIN_MOTOR_POWER, FULL_MOTOR_POWER)
				self.apply_force(motor_force_vector * motor_power / contact_count, contact_pos)

func _ready() -> void:
	# Different tanks would use the same resource, and share settings. We dont want that,
	#  because we will change the friction setting per tank
	self.physics_material_override = self.physics_material_override.duplicate()
