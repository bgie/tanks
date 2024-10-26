extends RigidBody2D

const FULL_MOTOR_POWER: float = 40_000
const MIN_POWER: float = 4_000
const MAX_VELOCITY: float = 300

func _integrate_forces(state: PhysicsDirectBodyState2D):
	var tank_movement: float = Input.get_axis("ui_left", 'ui_right')
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
				motor_power = clamp(motor_power, MIN_POWER, FULL_MOTOR_POWER)
				self.apply_force(motor_force_vector * motor_power / contact_count, contact_pos)
