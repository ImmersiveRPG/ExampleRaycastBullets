# Copyright (c) 2021-2023 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
# This file is licensed under the MIT License
# https://github.com/ImmersiveRPG/ExampleRaycastBullets

extends Node

const GAME_TITLE := "Godot Raycast Bullets"

const AIR_FRICTION := 10.0
const FLOOR_SLOPE_MAX_THRESHOLD := deg_to_rad(60)
const FLOOR_FRICTION := 60.0
const GRAVITY := -40.0
const MOUSE_SENSITIVITY := 0.1
const MOUSE_ACCELERATION_X := 10.0
const MOUSE_ACCELERATION_Y := 10.0
const MOUSE_Y_MAX := 70.0
const MOUSE_Y_MIN := -60.0

var _root_node : Node

@onready var _scene_bullet := ResourceLoader.load("res://src/Bullet/Bullet.tscn")
@onready var _scene_bullet_glow := ResourceLoader.load("res://src/BulletGlow/BulletGlow.tscn")
@onready var _scene_bullet_spark := ResourceLoader.load("res://src/BulletSpark/BulletSpark.tscn")

func create_bullet(parent : Node, start_pos : Vector3, target_pos : Vector3, bullet_type : Global.BulletType) -> void:
	var bullet = _scene_bullet.instantiate()
	parent.add_child(bullet)
	bullet.global_transform.origin = start_pos
	Global.safe_look_at(bullet, target_pos)
	bullet.start(bullet_type)

func create_bullet_spark(pos : Vector3) -> void:
	var spark = _scene_bullet_spark.instantiate()
	Global._root_node.add_child(spark)
	spark.global_transform.origin = pos

# See Transform::set_look_at for C++
# https://github.com/godotengine/godot/blob/3.4/core/math/transform.cpp#L78
func safe_look_at(spatial : Node3D, target: Vector3) -> void:
	var origin := spatial.global_transform.origin
	var v_z := (origin - target).normalized()

	# Just return if at same position
	if origin == target:
		return

	# Find an up vector that we can rotate around
	var up := Vector3.ZERO
	for entry in [Vector3.UP, Vector3.RIGHT, Vector3.BACK]:
		var v_x : Vector3 = entry.cross(v_z).normalized()
		if v_x.length() != 0:
			up = entry
			break

	# Look at the target
	if up != Vector3.ZERO:
		spatial.look_at(target, up)

enum Layers {
	terrain,
	item,
	player,
}

enum BulletType {
	_50BMG,
	_308,
	_556,
	_45,
	_9MM,
	_22LR,
	_12Gauge,
}

enum Element {
	Concrete,
	Steel,
	Glass,
	Plastic,
	Rubber,
	Aluminum,
}

const DB = {
	"Bullets" : {
		BulletType._50BMG : {
			"mass" : 0.023,
			"speed" : 1219.0,
			"max_distance" : 5000.0,
		},
		BulletType._308 : {
			"mass" : 0.018,
			"speed" : 1219.0,
			"max_distance" : 5000.0,
		},
		BulletType._556 : {
			"mass" : 0.016,
			"speed" : 1219.0,
			"max_distance" : 5000.0,
		},
		BulletType._45 : {
			"mass" : 0.0099,
			"speed" : 300.0,
			"max_distance" : 2000.0,
		},
		BulletType._9MM : {
			"mass" : 0.0075,
			"speed" : 400.0,
			"max_distance" : 2000.0,
		},
		BulletType._22LR : {
			"mass" : 0.0050,
			"speed" : 300.0,
			"max_distance" : 2000.0,
		},
		BulletType._12Gauge : {
			"mass" : 0.0025,
			"speed" : 200.0,
			"max_distance" : 500.0,
		},
	}
}
