# Copyright (c) 2021 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
# This file is license under the MIT License
# https://github.com/ImmersiveRPG/RaycastBullets

extends RigidBody


func fire(target : Vector3) -> void:
	var bullet_type = Global.BulletType._308

	var bullet := Global.create_bullet(bullet_type)
	Global._root_node.add_child(bullet)
	bullet.global_transform.origin = $BulletStartPosition.global_transform.origin
	bullet.look_at(target, Vector3.UP)
	bullet.setup_glow(bullet.global_transform.origin)

