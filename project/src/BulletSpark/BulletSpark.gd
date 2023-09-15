# Copyright (c) 2021-2023 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
# This file is licensed under the MIT License
# https://github.com/ImmersiveRPG/ExampleRaycastBullets

extends MeshInstance3D
class_name BulletSpark



func _on_die_timeout() -> void:
	self.queue_free()
