extends Control

# Pong 場景路徑，之後其他遊戲也可以照這個模式往下加。
const PONG_SCENE_PATH: String = "res://01_pong/scenes/game.tscn"

# 抓 Pong 按鈕，讓它在 _ready() 時接上 pressed 訊號。
@onready var pong_button: Button = $CenterContainer/MenuPanel/MarginContainer/VBoxContainer/PongButton

func _ready() -> void:
	# 按下按鈕後切換到 Pong 遊戲場景。
	pong_button.pressed.connect(_on_pong_button_pressed)

func _on_pong_button_pressed() -> void:
	# 載入 Pong 主場景；如果路徑錯誤，Godot 會在 console 報錯。
	get_tree().change_scene_to_file(PONG_SCENE_PATH)
