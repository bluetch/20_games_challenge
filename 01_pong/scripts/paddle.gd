extends CharacterBody2D

@export var move_speed: float = 400.0
@export var move_up_action: StringName
@export var move_down_action: StringName
@export var paddle_height: float = 120.0
# 平常顏色
@export var normal_color: Color = Color(1, 1, 1, 1)
# 被球打到時的顏色
@export var hit_color: Color = Color(1, 0.4, 0.4, 1)
@export var hit_flash_duration: float = 0.12
@onready var visual: ColorRect = $Visual


var top_limit: float = 0.0
var bottom_limit: float = 0.0
var start_x: float = 0.0
var is_active: bool = true

func _ready() -> void:
	start_x = global_position.x
	visual.color = normal_color

func _physics_process(delta: float) -> void:
	if not is_active:
		# 遊戲結束時停止處理輸入與移動
		velocity = Vector2.ZERO
		return

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

func flash_hit() -> void:
	# 先立刻切成受擊顏色
	visual.color = hit_color

	# 等待短短一段時間後，再切回原本顏色
	await get_tree().create_timer(hit_flash_duration).timeout
	visual.color = normal_color

func stop() -> void:
	# 讓球拍在 Game Over 後不再接受輸入
	is_active = false
	velocity = Vector2.ZERO
