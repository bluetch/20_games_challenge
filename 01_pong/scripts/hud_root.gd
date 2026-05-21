extends Control

@onready var player_1_score_label: Label = $SafeMargin/HUDVBox/TopBar/ScoreboardPanel/ScoreboardMargin/ScoreboardRow/Player1Group/Player1ScoreLabel
@onready var player_2_score_label: Label = $SafeMargin/HUDVBox/TopBar/ScoreboardPanel/ScoreboardMargin/ScoreboardRow/Player2Group/Player2ScoreLabel
@onready var winner_label: Label = $SafeMargin/HUDVBox/StatusCenter/StatusVBox/WinnerLabel
@onready var game_over_center: CenterContainer = $GameOverCenter
@onready var play_again_button: Button = %PlayAgainButton

func reset() -> void:
	winner_label.text = ""
	game_over_center.visible = false
	
func show_countdown(count: int) -> void:
	winner_label.text = str(count)

func clear_status() -> void:
	winner_label.text = ""

func update_scores(player_1_score: int, player_2_score: int) -> void:
	player_1_score_label.text = str(player_1_score)
	player_2_score_label.text = str(player_2_score)

func show_winner(winner_text: String) -> void:
	winner_label.text = winner_text
	game_over_center.visible = true
	play_again_button.grab_focus()
