# Copyright (c) 2021-2023 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
# This file is licensed under the MIT License
# https://github.com/ImmersiveRPG/ExampleRaycastBullets

extends RigidBody3D


var _element := Global.Element.Aluminum

func fire(target_pos : Vector3) -> void:
	var bullet_type := Global.BulletType._308
	var start_pos = $BulletStartPosition.global_transform.origin
	Global.create_bullet(Global._root_node, start_pos, target_pos, bullet_type)


