# Copyright (c) 2021-2023 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
# This file is licensed under the MIT License
# https://github.com/ImmersiveRPG/ExampleRaycastBullets

extends MeshInstance3D
class_name BulletGlow

var _points : Array[Vector3] = []
var _prev_pos := Vector3.ZERO
var _parent_bullet : Node3D = null
var _immediate_mesh : ImmediateMesh = null

func _ready() -> void:
	_immediate_mesh = self.mesh

func _physics_process(delta : float) -> void:
	# If the parent bullet still exists, add a point when it moves at least a meter
	if _parent_bullet != null and is_instance_valid(_parent_bullet):
		var position := _parent_bullet.global_transform.origin
		var distance := _prev_pos.distance_to(position)
		if distance > 1.0:
			_prev_pos = position

			# Save position as local space
			_points.append(position - self.global_transform.origin)

			if _points.size() > 5:
				_points.pop_front()
	else:
		# If the bullet is destroyed, delete the points
		if not _points.is_empty():
			_points.pop_front()
		else:
			self.queue_free()

func _process(_delta : float) -> void:
	if not _immediate_mesh: return
	if _points.size() < 4: return

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

func start(bullet : Node3D) -> void:
	_parent_bullet = bullet
	_points.append(Vector3(0, 0, 0))
	self._physics_process(0.0)
