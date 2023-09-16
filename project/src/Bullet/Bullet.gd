# Copyright (c) 2021-2023 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
# This file is licensed under the MIT License
# https://github.com/ImmersiveRPG/ExampleRaycastBullets

extends Node3D
class_name Bullet

var _bullet_type := -1
var _mass := -1.0
var _max_distance := -1.0
var _glow = null
var _speed := 0.0
var _velocity : Vector3
var _gravity_velocity := 0.0
var _is_setup := false

var _total_distance := 0.0
@onready var _ray : RayCast3D = $RayCast3D

# NOTE: Make sure min bounce distance is greater than max raycast distance
const MIN_BOUNCE_DISTANCE := 0.5
const MIN_RAYCAST_DISTANCE := 0.3

func _physics_process(delta : float) -> void:
	if not _is_setup: return

	# Move the bullet
	var distance := _velocity.length() * delta
	self.transform.origin -= _velocity * delta

	# Gravity
	_gravity_velocity = clampf(_gravity_velocity + 9.8 * delta, 0, 9.8)
	self.transform.origin.y -= _gravity_velocity

	# Change the ray start position to the bullets's previous position
	# NOTE: The ray is backwards, so if it is hitting multiple targets, we
	# get the target closest to the bullet start position.
	# Also make the ray at least the min length
	if distance > MIN_RAYCAST_DISTANCE:
		_ray.target_position.z = -distance
		_ray.transform.origin.z = distance
	else:
		_ray.target_position.z = -MIN_RAYCAST_DISTANCE
		_ray.transform.origin.z = MIN_RAYCAST_DISTANCE

	# Delete the bullet if it hit something
	_ray.force_raycast_update()
	if _ray.is_colliding():
		var collider := _ray.get_collider()
		print("Bullet hit %s" % [collider.name])

		# Move the bullet back to the position of the collision
		self.global_transform.origin = _ray.get_collision_point()

		# Ricochet the bullet if the item is steel or concrete
		if collider.is_in_group("element") and collider._element in [Global.Element.Steel, Global.Element.Concrete]:
			# Remove 20% of the speed
			_speed = clampf(_speed - _speed * 0.20, 0.0, 10000.0)
			_velocity = self.transform.basis.z * _speed

			# Reset gravity
			_gravity_velocity = 0.0

			# Bounce
			var norm := _ray.get_collision_normal()
			_velocity = _velocity.bounce(norm)
			Global.safe_look_at(self, self.global_transform.origin - _velocity)

			# Move away from collision location to avoid still touching it,
			# or raycast tail still touching it
			self.transform.origin -= self.transform.basis.z * MIN_BOUNCE_DISTANCE
		# Hit object
		elif collider.is_in_group("item"):
			# Nudge the object
			var force := _mass * _velocity.length()
			collider.emit_signal("apply_force", -self.transform.basis.z, force)
			self.queue_free()
		# Hit something unexpected
		else:
			self.queue_free()

		# Add bullet spark
		Global.create_bullet_spark(self.global_transform.origin)

	# Delete the bullet if it is slow
	if distance < 1.0:
		self.queue_free()

	# Delete the bullet if it has gone its max distance
	_total_distance += distance
	if _total_distance > _max_distance:
		self.queue_free()

func start(bullet_type : Global.BulletType) -> void:
	# Get the bullet info from the database
	_bullet_type = bullet_type
	var entry : Dictionary = Global.DB["Bullets"][_bullet_type]
	_mass = entry["mass"]
	_max_distance = entry["max_distance"]
	_speed = entry["speed"]
	_velocity = self.transform.basis.z * _speed
	#print("Loaded values for %s" % self.name)

	# Add bullet glow
	_glow = Global._scene_bullet_glow.instantiate()
	Global._root_node.add_child(_glow)
	_glow.global_transform.origin = self.global_transform.origin
	_glow.start(self)

	_is_setup = true
