extends Node2D

# 抓 Ball 節點，之後要接它發出的 scored signal
@onready var ball: CharacterBody2D = %Ball

@onready var left_paddle: CharacterBody2D = %LeftPaddle
@onready var right_paddle: CharacterBody2D = %RightPaddle

# 抓 HUDRoot，畫面更新交給 hud_root.gd 處理
@onready var hud_root: Control = %HUDRoot
@onready var play_again_button: Button = %PlayAgainButton
@onready var quit_button: Button = %QuitButton

# 初始化數據
var player_1_score: int = 0
var player_2_score: int = 0
var is_game_over: bool = false
@export var winning_score: int = 3
@export var start_countdown: int = 3

func _ready() -> void:	
	# 把 Ball 的 scored signal 連到 _on_ball_scored
	ball.scored.connect(_on_ball_scored)
	_set_paddle_limits()
	
	# 開場先重設 HUD 顯示狀態
	hud_root.reset()

	# 遊戲開始先更新一次畫面分數
	update_score_labels()
	await _run_start_countdown()
	ball.start_serve(Vector2.RIGHT)
	
	# 接上 Game Over 按鈕事件
	play_again_button.pressed.connect(_on_play_again_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)

func _run_start_countdown() -> void:
	for count in range(start_countdown, 0, -1):
		hud_root.show_countdown(count)
		await get_tree().create_timer(1.0).timeout

	hud_root.clear_status()

func _set_paddle_limits() -> void:
	# 用上下牆的位置設定球拍可移動範圍，避免在球拍 script 裡寫死數字
	var top_wall_shape: CollisionShape2D = $TopWall/CollisionShape2D
	var bottom_wall_shape: CollisionShape2D = $BottomWall/CollisionShape2D

	left_paddle.top_limit = top_wall_shape.global_position.y
	left_paddle.bottom_limit = bottom_wall_shape.global_position.y
	right_paddle.top_limit = top_wall_shape.global_position.y
	right_paddle.bottom_limit = bottom_wall_shape.global_position.y

func _on_ball_scored(player_id: int) -> void:
	if is_game_over:
		return
		
	# 根據 signal 傳來的玩家編號加分
	if player_id == 1:
		player_1_score += 1
	elif player_id == 2:
		player_2_score += 1

	# 更新畫面上的分數文字
	update_score_labels()

	# 加分後立刻檢查有沒有人獲勝
	check_winner()

func update_score_labels() -> void:
	# 把最新分數交給 HUD 顯示
	hud_root.update_scores(player_1_score, player_2_score)

func check_winner() -> void:
	# Player 1 先到勝利分數，顯示獲勝訊息並停止球
	if player_1_score >= winning_score:
		_end_game("Player 1 Wins")

	# Player 2 先到勝利分數，顯示獲勝訊息並停止球
	elif player_2_score >= winning_score:
		_end_game("Player 2 Wins")

func _end_game(winner_text: String) -> void:
	# 統一處理遊戲結束時的 HUD 與球的狀態
	is_game_over = true
	hud_root.show_winner(winner_text)
	ball.stop()
		
func _on_play_again_button_pressed() -> void:
	get_tree().reload_current_scene()

func _on_quit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menu/scenes/main_menu.tscn")
