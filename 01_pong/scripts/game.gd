extends Node2D

# 抓 Ball 節點，之後要接它發出的 scored signal
@onready var ball: CharacterBody2D = $Ball

# 抓兩個分數 Label
@onready var player_1_score_label: Label = $UI/HUD/Player1ScoreLabel
@onready var player_2_score_label: Label = $UI/HUD/Player2ScoreLabel

# 抓勝利訊息 Label
@onready var winner_label: Label = $UI/HUD/WinnerLabel

# 紀錄分數資料
var player_1_score: int = 0
var player_2_score: int = 0

# 勝利分數門檻
var winning_score: int = 5

func _ready() -> void:
	# 把 Ball 的 scored signal 連到 _on_ball_scored
	ball.scored.connect(_on_ball_scored)

	# 一開始先清空勝利文字
	winner_label.text = ""

	# 遊戲開始先更新一次畫面分數
	update_score_labels()

func _on_ball_scored(player_id: int) -> void:
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
	# 把最新分數顯示到 Label
	player_1_score_label.text = "Player 1: " + str(player_1_score)
	player_2_score_label.text = "Player 2: " + str(player_2_score)

func check_winner() -> void:
	# Player 1 先到勝利分數，顯示獲勝訊息並停止球
	if player_1_score >= winning_score:
		winner_label.text = "Player 1 Wins"
		ball.set_physics_process(false)

	# Player 2 先到勝利分數，顯示獲勝訊息並停止球
	elif player_2_score >= winning_score:
		winner_label.text = "Player 2 Wins"
		ball.set_physics_process(false)
