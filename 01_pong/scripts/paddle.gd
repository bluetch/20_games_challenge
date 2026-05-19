extends CharacterBody2D

@export var move_speed: float = 400.0
@export var move_up_action: StringName
@export var move_down_action: StringName

func _physics_process(delta: float) -> void:
	var direction: float = Input.get_axis(move_up_action, move_down_action)
	velocity = Vector2(0.0, direction * move_speed)
	move_and_slide()
