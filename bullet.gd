extends RigidBody2D

const WIND_RESISTANCE_FACTOR: float = 0.5

func _integrate_forces(state: PhysicsDirectBodyState2D):
	var speed = self.linear_velocity.length()
	if speed > 0.1:
		var wind_resistance_angle = state.linear_velocity.angle() - rotation
		while wind_resistance_angle > PI:
			wind_resistance_angle -= 2*PI
		while wind_resistance_angle < -PI:
			wind_resistance_angle += 2*PI
		var torque: float = wind_resistance_angle * speed * WIND_RESISTANCE_FACTOR * mass
		state.apply_torque(torque)

func _on_warhead_area_body_entered(body: Node2D) -> void:
	if body != self:
		explode()

func explode() -> void:
	Explosion.spawn(self)
	queue_free()
