# Copyright (c) 2021 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
# This file is license under the MIT License
# https://github.com/ImmersiveRPG/RaycastBullets

extends MeshInstance
class_name BulletSpark



func _on_die_timeout() -> void:
	self.queue_free()
