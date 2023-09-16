# Copyright (c) 2021-2023 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
# This file is licensed under the MIT License
# https://github.com/ImmersiveRPG/ExampleRaycastBullets

extends RigidBody3D

signal apply_force(angle : Vector3, force : float)

var _element := Global.Element.Steel
var _rand_rotation_force := Vector3.ZERO

func _on_apply_force(angle : Vector3, force : float) -> void:
	self.apply_central_impulse(force * angle)

func _process(delta : float) -> void:
	self.rotation_degrees += _rand_rotation_force * delta


func _on_timeout() -> void:
	var power := 200.0
	_rand_rotation_force.x = randf_range(-power, power)
	_rand_rotation_force.y = randf_range(-power, power)
	_rand_rotation_force.z = randf_range(-power, power)
