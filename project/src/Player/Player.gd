# Copyright (c) 2021 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
# This file is licensed under the MIT License
# https://github.com/ImmersiveRPG/ExampleRaycastBullets

extends KinematicBody
class_name Player

const WALK_ACCELERATION := 70.0
const WALK_MAX_VELOCITY := 10.0
const ROTATION_SPEED := 10.0


var _latest_mouse_pos := Vector2.ZERO
var _input_vector := Vector3.ZERO
var _velocity := Vector3.ZERO
var _snap_vector := Vector3.ZERO
var _looking_at = null
var _camera_x := 0.0
var _camera_x_new := 0.0
var _camera_y := 0.0



func _input(event : InputEvent) -> void:
	# Rotate camera with mouse
	if event is InputEventMouseMotion:
		_camera_x -= event.relative.x * Global.MOUSE_SENSITIVITY
		_camera_y = clamp(_camera_y - event.relative.y * Global.MOUSE_SENSITIVITY, Global.MOUSE_Y_MIN, Global.MOUSE_Y_MAX)

	# Update the latest mouse position
	if event is InputEventMouse:
		_latest_mouse_pos = event.position

func _process(delta : float) -> void:
	# Angle the camera
	var camera = $CameraMount/v/Camera
	_camera_x_new = lerp(_camera_x_new, _camera_x, delta * Global.MOUSE_ACCELERATION_X)
	self.rotation_degrees.y = _camera_x_new
	$CameraMount/v.rotation_degrees.x = lerp($CameraMount/v.rotation_degrees.x, _camera_y, delta * Global.MOUSE_ACCELERATION_X)

	# Figure out what we are looking at
	var look_at := $CameraMount/v/Camera/RayMount/LookAtRayCast
	look_at.force_raycast_update()
	var thing = look_at.get_collider()
	if thing:
		if thing != _looking_at:
			_looking_at = thing
			print("Looking at %s(%s)" % [thing.name, thing.get_class()])
	elif _looking_at:
		_looking_at = null

	# Check keyboard input
	_input_vector = Vector3.ZERO
	_input_vector.x = Input.get_action_strength("MoveRight") - Input.get_action_strength("MoveLeft")
	_input_vector.z = Input.get_action_strength("MoveBack") - Input.get_action_strength("MoveForward")
	_input_vector = _input_vector.normalized()

	var is_shooting := false
	if Input.is_action_just_pressed("Shoot"):
		is_shooting = true

	# Get ray where camera is pointing
	var target := Vector3.INF
	var ray_length := 300
	var from = camera.project_ray_origin(_latest_mouse_pos)
	var to = from + camera.project_ray_normal(_latest_mouse_pos) * ray_length
	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray(from, to)
	target = result.position if result else to

	# Make player aim where ray is pointing
	if target != Vector3.INF:
		var arm := $Pivot/Body/RShoulder
		arm.look_at(target, Vector3.UP)

	# Shooting
	if is_shooting:
		for weapon in $Pivot/Body/RShoulder/ItemMount.get_children():
			weapon.fire(target)

func _physics_process(delta : float) -> void:
	# Check if moving
	var input_direction : Vector3 = (_input_vector.x * transform.basis.x) + (_input_vector.z * transform.basis.z)
	var is_moving : bool = input_direction != Vector3.ZERO

	# Velocity
	var max_velocity := WALK_MAX_VELOCITY

	# Acceleration
	var acceleration := WALK_ACCELERATION
	if is_moving:
		_velocity.x = _velocity.move_toward(input_direction * max_velocity, acceleration * delta).x
		_velocity.z = _velocity.move_toward(input_direction * max_velocity, acceleration * delta).z

	# Rotate towards movement direction
	if is_moving:
		$Pivot.rotation.y = lerp_angle($Pivot.rotation.y, atan2(-_input_vector.x, -_input_vector.z), ROTATION_SPEED * delta)

	# Ground and air friction
	if not is_moving:
		if is_on_floor():
			_velocity = _velocity.move_toward(Vector3.ZERO, Global.FLOOR_FRICTION * delta)
		else:
			_velocity.x = _velocity.move_toward(input_direction * max_velocity, Global.AIR_FRICTION * delta).x
			_velocity.z = _velocity.move_toward(input_direction * max_velocity, Global.AIR_FRICTION * delta).z

	# Gravity
	_velocity.y = clamp(_velocity.y + Global.GRAVITY * delta, Global.GRAVITY, -Global.GRAVITY)

	# Snap to floor plane if close enough
	_snap_vector = -get_floor_normal() if is_on_floor() else Vector3.DOWN

	# Actually move
	_velocity = move_and_slide_with_snap(_velocity, _snap_vector, Vector3.UP, true, 4, Global.FLOOR_SLOPE_MAX_THRESHOLD, false)


