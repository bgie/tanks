extends RigidBody2D

const WIND_RESISTANCE_FACTOR: float = 0.005

func _integrate_forces(state: PhysicsDirectBodyState2D):
	var speed = self.linear_velocity.length()
	if speed > 0.1:
		var wind_resistance_angle = state.linear_velocity.angle() - rotation
		if wind_resistance_angle > PI:
			wind_resistance_angle -= 2*PI
		elif wind_resistance_angle < PI:
			wind_resistance_angle += 2*PI
		state.apply_torque(wind_resistance_angle * wind_resistance_angle * speed * WIND_RESISTANCE_FACTOR * mass)

func _on_warhead_area_body_entered(body: Node2D) -> void:
	if body != self:
		Explosion.spawn(self)
		queue_free()
