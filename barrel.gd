extends RigidBody2D

func explode() -> void:
	Explosion.spawn(self)
	queue_free()
