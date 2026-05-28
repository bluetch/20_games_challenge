extends CharacterBody2D

# 球拍可由玩家或電腦控制
enum ControlMode {
	HUMAN,
	CPU
}

@export var move_speed: float = 400.0
@export var move_up_action: StringName
@export var move_down_action: StringName
@export var paddle_height: float = 120.0

# 在 Inspector 決定這支球拍是玩家還是電腦
@export var control_mode: ControlMode = ControlMode.HUMAN
# 指定材質
@export var paddle_texture: Texture2D

# 給 CPU 用來追蹤球的位置
@export var ball_path: NodePath
@export var hit_flash_duration: float = 0.12

@onready var visual: Sprite2D = $Visual
@onready var ball: CharacterBody2D = get_node_or_null(ball_path)

var top_limit: float = 0.0
var bottom_limit: float = 0.0
var start_x: float = 0.0
var is_active: bool = true

func _ready() -> void:
	if paddle_texture != null:
		visual.texture = paddle_texture
	start_x = global_position.x

func _physics_process(delta: float) -> void:
	if not is_active:
		velocity = Vector2.ZERO
		return

	var direction: float = _get_move_direction()
	velocity = Vector2(0.0, direction * move_speed)
	move_and_slide()

	var screen_height: float = get_viewport_rect().size.y
	var max_y: float = screen_height - paddle_height

	if bottom_limit > top_limit:
		max_y = bottom_limit - paddle_height

	global_position.y = clamp(global_position.y, top_limit, max_y)
	global_position.x = start_x

func _get_move_direction() -> float:
	# 玩家模式：直接讀輸入
	if control_mode == ControlMode.HUMAN:
		return Input.get_axis(move_up_action, move_down_action)

	# 電腦模式：追球的中心點
	return _get_cpu_direction()

func _get_cpu_direction() -> float:
	# 沒指定球時，不移動，避免報錯
	if ball == null:
		return 0.0

	var paddle_center_y: float = global_position.y + paddle_height / 2.0
	var ball_y: float = ball.global_position.y
	var dead_zone: float = 12.0

	# 加一個 dead zone，避免 CPU 在小範圍內抖動
	if abs(ball_y - paddle_center_y) <= dead_zone:
		return 0.0

	if ball_y < paddle_center_y:
		return -1.0

	return 1.0

func flash_hit() -> void:
	# 先立刻切成受擊顏色
	# visual.color = hit_color

	# 等待短短一段時間後，再切回原本顏色
	await get_tree().create_timer(hit_flash_duration).timeout
	# visual.color = normal_color

func stop() -> void:
	# 讓球拍在 Game Over 後不再接受輸入或 CPU 控制
	is_active = false
	velocity = Vector2.ZERO
