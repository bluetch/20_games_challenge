extends CharacterBody2D

@export var move_speed: float = 400.0
@export var move_up_action: StringName
@export var move_down_action: StringName
@export var paddle_height: float = 120.0

var top_limit: float = 0.0
var bottom_limit: float = 0.0
var start_x: float = 0.0

func _ready() -> void:
	start_x = global_position.x

func _physics_process(delta: float) -> void:
	var direction: float = Input.get_axis(move_up_action, move_down_action)
	velocity = Vector2(0.0, direction * move_speed)
	move_and_slide()
	
	# 限制球拍不要超出視窗上下邊界
	var screen_height: float = get_viewport_rect().size.y
	var max_y: float = screen_height - paddle_height
	
	if bottom_limit > top_limit:
		max_y = bottom_limit - paddle_height
		
	global_position.y = clamp(global_position.y, top_limit, max_y)
	global_position.x = start_x
