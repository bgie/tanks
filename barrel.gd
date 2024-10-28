extends RigidBody2D

const DEATH_EXPLOSION_SIZE := 1.4

func explode() -> void:
	Explosion.spawn(self, DEATH_EXPLOSION_SIZE)
	queue_free()
