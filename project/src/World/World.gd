# Copyright (c) 2021 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
# This file is license under the MIT License
# https://github.com/ImmersiveRPG/ExampleRaycastBullets

extends Spatial


func _ready() -> void:
	Global._root_node = self

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$Player.set_process_input(true)
	$Player.set_process(true)

func _input(event) -> void:
	if Input.is_action_just_pressed("Quit"):
		self.get_tree().quit()
