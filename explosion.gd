class_name Explosion extends Area2D

const BLAST_FORCE: float = 20_000_000_000.0
const scene := preload("res://explosion.tscn")
const MIN_BLAST_RADIUS := 10.0

@onready var blast_radius: float = $CollisionShape2D.shape.radius
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var explosion_area: Area2D = $ExplosionArea

static func spawn(source: Node2D) -> Node2D:
	var explosion = scene.instantiate()
	explosion.position = source.global_position
	source.get_parent().add_child.call_deferred(explosion)
	return explosion

func _physics_process(delta: float) -> void:
	for body in get_overlapping_bodies():
		if body is RigidBody2D:
			var difference := body.position - self.position
			var distance_squared: float = max(MIN_BLAST_RADIUS, difference.length_squared())
			body.apply_central_force(difference.normalized() * BLAST_FORCE * delta / distance_squared)

func _ready() -> void:
	animated_sprite_2d.rotation_degrees = randf_range(0, 90)

func explosion_finished() -> void:
	self.set_physics_process(false)
	explosion_area.monitoring = false

func _on_explosion_area_body_entered(body: Node2D) -> void:
	if body.has_method("explode"):
		body.explode()
