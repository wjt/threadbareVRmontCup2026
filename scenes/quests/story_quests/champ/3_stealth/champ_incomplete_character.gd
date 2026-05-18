# SPDX-FileCopyrightText: The Threadbare Authors
# SPDX-License-Identifier: MPL-2.0
extends CharacterBody2D

const SPEED = 300.0
var input_vector: Vector2

@export_group("Movement")
@export_range(10, 100000, 10) var stopping_step: float = 1500.0
@export_range(10, 100000, 10) var moving_step: float = 4000.0

@export_group("Abilities")
@export var tile_layer: TileMapLayer
@export var blink_check: Area2D
@export var blink_check_sprite: Sprite2D
@export var blink_bounds: Area2D
@export_range(0,24,0.5,"suffix:tiles") var blink_distance = 7.0

enum Mode { FIGHTING, DEFEATED }
var mode: Mode = Mode.FIGHTING

func _physics_process(delta: float) -> void:
	if mode == Mode.DEFEATED:
		velocity = Vector2.ZERO
		return
	
	
	var axis = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	input_vector = axis * SPEED
	
	
	var step := (
		stopping_step if velocity.length_squared() > input_vector.length_squared() else moving_step
	)
	
	if velocity.length() > 0: 
		$AnimatedSprite2D.play("walk")
	else: 
		$AnimatedSprite2D.play("idle")
	
	velocity = velocity.move_toward(input_vector, step * delta)
	move_and_slide()

func _unhandled_input(_event: InputEvent) -> void:
	if(Input.is_action_just_pressed(&"key_c")):
		_apply_blink()
	
	
	if(Input.is_action_just_pressed(&"key_f")):
		_toggle_water_walk()

func _apply_blink() -> void:
	
	if mode == Mode.DEFEATED or not blink_check or not blink_bounds:
		return

	
	if input_vector == Vector2.ZERO:
		return

	var blink_distance_pixels = blink_distance * 64
	var blink_direction := input_vector.normalized()
	var target_coordinates: Vector2 = global_position + blink_direction * blink_distance_pixels

	blink_check.global_position = target_coordinates
	blink_check.force_update_transform()
	
	if blink_check_sprite:
		blink_check_sprite.show()
	
	await get_tree().create_timer(0.1).timeout

	
	if blink_bounds.overlaps_area(blink_check):
		if not blink_check.has_overlapping_bodies():
			global_position = target_coordinates
			
	if blink_check_sprite:
		blink_check_sprite.hide()

func _toggle_water_walk() -> void:
	
	if not tile_layer:
		print("Warning: No TileMapLayer assigned for water walking!")
		return
		
	
	tile_layer.enabled = !tile_layer.enabled
	
	
	if !tile_layer.enabled:
		modulate = Color(0.5, 0.8, 1.0) 
	else:
		modulate = Color.WHITE

func defeat() -> void:
	if mode == Mode.DEFEATED: return
	mode = Mode.DEFEATED
	await get_tree().create_timer(2.0).timeout
	SceneSwitcher.reload_with_transition(Transition.Effect.FADE, Transition.Effect.FADE)
