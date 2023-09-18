# Copyright (c) 2021-2023 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
# This file is licensed under the MIT License
# https://github.com/ImmersiveRPG/ExampleRaycastBullets

extends MeshInstance3D
class_name BulletGlow

var _points : Array[Vector3] = []
var _prev_pos := Vector3.ZERO
var _is_parent_bullet_destroyed := false

@onready var _immediate_mesh : ImmediateMesh = self.mesh

func update(parent_pos : Vector3) -> void:
	# Add another point if it moved far enough
	var distance := _prev_pos.distance_to(parent_pos)
	if distance > 0.1:
		_prev_pos = parent_pos

		# Save position as local space
		_points.append(parent_pos - self.global_transform.origin)

		if _points.size() > 6:
			_points.pop_front()

func _physics_process(_delta : float) -> void:
	# If the bullet is destroyed, delete the points
	if _is_parent_bullet_destroyed:
		if not _points.is_empty():
			_points.pop_front()
		else:
			self.queue_free()

func _process(_delta : float) -> void:
	if not _immediate_mesh: return
	if _points.size() < 2: return

	# Draw the line
	_immediate_mesh.clear_surfaces()
	_immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	for i in _points.size():
		if i + 1 < _points.size():
			var a := _points[i]
			var b := _points[i + 1]
			_immediate_mesh.surface_add_vertex(a)
			_immediate_mesh.surface_add_vertex(b)
	_immediate_mesh.surface_end()

func start(parent_pos : Vector3) -> void:
	_points.append(parent_pos - self.global_transform.origin)
