# Copyright (c) 2021 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
# This file is license under the MIT License
# https://github.com/ImmersiveRPG/ExampleRaycastBullets

extends Spatial
class_name Bullet

var _bullet_type := -1
var _mass := -1.0
var _speed := -1.0
var _max_distance := -1.0
var _ignore_collision_distance := 0.0
var _glow = null
var _velocity : Vector3

var _total_distance := 0.0
onready var _ray = $RayCast

func start() -> void:
	_velocity = self.transform.basis.z * _speed

func _load_db_values(bullet_type : int) -> Bullet:
	_bullet_type = bullet_type
	var entry = Global.DB["Bullets"][_bullet_type]
	_mass = entry["mass"]
	_speed = entry["speed"]
	_max_distance = entry["max_distance"]
	#print("Loaded values for %s" % self.name)
	return self

func _exit_tree() -> void:
	if _glow:
		_glow.queue_free()
		_glow = null

func setup_glow(pos : Vector3) -> void:
	# Add bullet glow
	_glow = Global.create_bullet_glow()
	Global._root_node.add_child(_glow)
	_glow.global_transform.origin = pos
	_glow.update(pos)

func _physics_process(delta : float) -> void:
	# Move the bullet
	var distance := _speed * delta
	self.transform.origin -= _velocity * delta
	#MarkerCube.add(self.transform.origin, Color.blue)

	# Gravity
	#self.transform.origin.y -= 9.8 * delta

	# Change the ray start position to the bullets's previous position
	# NOTE: The ray is backwards, so if it is hitting multiple targets, we
	# get the target closest to the bullet start position.
	# Also make the ray at least 1 meter long
	if distance > 1.0:
		_ray.cast_to.z = -distance
		_ray.transform.origin.z = distance
	else:
		_ray.cast_to.z = -1.0
		_ray.transform.origin.z = 1.0

	if _ignore_collision_distance > 0.0:
		_ignore_collision_distance -= distance

	# Delete the bullet if it hit something
	_ray.force_raycast_update()
	if _ray.is_colliding() and _ignore_collision_distance <= 0.0:
		_ignore_collision_distance = 2.0
		var collider = _ray.get_collider()
		print("Bullet hit %s" % [collider.name])

		# Move the bullet back to the position of the collision
		self.global_transform.origin = _ray.get_collision_point()

		# Add bullet spark
		var bullet_spark = Global.create_bullet_spark()
		self.get_parent().add_child(bullet_spark)
		bullet_spark.global_transform.origin = _ray.get_collision_point()

		var force := _mass * _speed

		if collider.is_in_group("item"):
			# Nudge the object
			collider.emit_signal("apply_force", -self.transform.basis.z, force)

			# Ricochet the bullet if the item is steel or concrete
			if collider._element in [Global.Element.Steel, Global.Element.Concrete]:
				# Remove 20% of the bullet's speed
				_speed -= (_speed * 0.20)

				# Bounce
				var norm = _ray.get_collision_normal()
				_velocity = _velocity.bounce(norm)
				self.look_at(global_transform.origin - _velocity, Vector3.UP)
			else:
				self.queue_free()
		else:
			self.queue_free()

	# Delete the bullet if it has gone its max distance
	_total_distance += distance
	if _total_distance > _max_distance:
		self.queue_free()

	# Add bullet glow
	if _glow:
		_glow.update(self.global_transform.origin)
