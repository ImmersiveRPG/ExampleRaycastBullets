# Copyright (c) 2021 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
# This file is licensed under the MIT License
# https://github.com/ImmersiveRPG/ExampleRaycastBullets

extends RigidBody

signal apply_force(angle, force)

var _element : int = Global.Element.Aluminum

func _on_apply_force(angle : Vector3, force : float) -> void:
	self.apply_central_impulse(force * angle)

