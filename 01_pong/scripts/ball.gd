extends CharacterBody2D

# scored signal 會把得分玩家編號傳出去
signal scored(player_id: int)

# 球的移動速度
@export var move_speed: float = 300.0
@export var serve_angle_range: float = 0.35
@onready var serve_timer: Timer = $ServeTimer

# 球目前的移動方向
var move_direction: Vector2 = Vector2.RIGHT

# 球目前是否正在等待重新發球
var is_serving: bool = true

# 記住下一次發球方向
var next_serve_direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	# 把 Timer timeout signal 連到重新發球函式
	serve_timer.timeout.connect(_on_serve_timer_timeout)

func _physics_process(delta: float) -> void:
	# 如果目前在等待發球，就先不要移動
	if is_serving:
		return

	# 取得目前視窗大小，避免把解析度寫死
	var screen_size: Vector2 = get_viewport_rect().size

	# 用方向、速度、delta 算出這一幀要移動的距離
	var collision: KinematicCollision2D = move_and_collide(move_direction * move_speed * delta)

	# 如果這一幀有撞到東西，就處理反彈
	if collision:
		# 取得被撞到的物件
		var collider := collision.get_collider()

		# 如果撞到的是球拍，就依照擊中位置改變反彈角度
		if collider.is_in_group("paddles"):
			# 球拍中心點 = 根節點 y + 半個球拍高度
			var paddle_half_height: float = collider.paddle_height / 2.0
			var paddle_center_y: float = collider.global_position.y + paddle_half_height

			# 球和球拍中心的垂直距離
			var hit_offset: float = global_position.y - paddle_center_y

			# 把偏移量縮放到大約 -1 到 1 的範圍
			var normalized_offset: float = clamp(hit_offset / paddle_half_height, -1.0, 1.0)

			# 球碰到球拍後，X 方向反轉
			move_direction.x *= -1.0

			# 用擊中位置決定新的 Y 方向
			move_direction.y = normalized_offset

			# 正規化方向，避免速度忽快忽慢
			move_direction = move_direction.normalized()
		else:
			# 撞到牆時，用一般反彈公式
			move_direction = move_direction.bounce(collision.get_normal()).normalized()

	# 如果球跑出左邊畫面，代表 Player 2 得分
	if global_position.x < 0.0:
		# 發出得分 signal，通知主場景更新分數
		scored.emit(2)

		# 重新發球，下一球往右
		start_reset_and_serve(Vector2.RIGHT)
		return

	# 如果球跑出右邊畫面，代表 Player 1 得分
	if global_position.x > screen_size.x:
		# 發出得分 signal，通知主場景更新分數
		scored.emit(1)

		# 重新發球，下一球往左
		start_reset_and_serve(Vector2.LEFT)
		return

func start_reset_and_serve(new_direction: Vector2) -> void:
	# 取得目前視窗大小，準備把球放回畫面中心
	var screen_size: Vector2 = get_viewport_rect().size

	# 把球放回畫面中心
	global_position = screen_size / 2.0

	# 記住下一次發球方向
	next_serve_direction = new_direction

	# 進入等待發球狀態
	is_serving = true

	# 啟動延遲發球計時器
	serve_timer.start()
	
func start_serve(new_direction: Vector2) -> void:
	_set_random_serve_direction(new_direction)
	is_serving = false
	

func _on_serve_timer_timeout() -> void:
	# 計時結束後，球才開始重新移動
	var random_y: float = randf_range(-serve_angle_range, serve_angle_range)
	move_direction = Vector2(next_serve_direction.x, random_y).normalized()
	_set_random_serve_direction(next_serve_direction)
	is_serving = false

func _set_random_serve_direction(new_direction: Vector2) -> void:
	var random_y: float = randf_range(-serve_angle_range, serve_angle_range)
	move_direction = Vector2(new_direction.x, random_y).normalized()
