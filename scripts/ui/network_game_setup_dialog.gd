extends Control
class_name NetworkGameSetupDialog

## 网络游戏设置对话框

## BGM
var bgm: AudioStream

@onready var dialog_container: Control = $DialogContainer
@onready var title_label: Label = $DialogContainer/TitleLabel
@onready var game_mode_label: Label = $DialogContainer/GameModeLabel
@onready var map_selection_container: VBoxContainer = $DialogContainer/MapSelectionContainer
@onready var faction_selection_container: VBoxContainer = $DialogContainer/FactionSelectionContainer
@onready var confirm_button: Button = $DialogContainer/ConfirmButton
@onready var cancel_button: Button = $DialogContainer/CancelButton

## 游戏模式选项
var game_modes: Dictionary = {
	"adventure": "冒险模式",
	"survival": "生存模式",
	"mini_game": "迷你游戏",
	"puzzle": "解密模式",
	"custom": "自定义关卡"
}

## 地图选项
var map_options: Dictionary = {
	"day": "白天",
	"night": "夜晚",
	"pool": "泳池",
	"fog": "迷雾",
	"roof": "屋顶"
}

## 阵营选项
var faction_options: Dictionary = {
	"plants": "植物阵营",
	"zombies": "僵尸阵营",
	"mixed": "混合阵营"
}

## 当前选择的游戏模式
var current_game_mode: String = "adventure"

## 当前选择的地图
var current_map: String = "day"

## 当前选择的阵营
var current_faction: String = "plants"

## 是否为地图选择模式
var is_map_selection: bool = false

## 是否为阵营选择模式
var is_faction_selection: bool = false

## 回调函数
var callback: Callable = func(): pass

## 初始化对话框
func _ready() -> void:
	# 隐藏对话框
	dialog_container.visible = false

	# 初始化UI
	_init_game_mode_selection()
	_init_map_selection()
	_init_faction_selection()

	# 设置按钮连接
	confirm_button.pressed.connect(_on_confirm_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)

	# 播放BGM
	SoundManager.play_bgm(bgm)

## 初始化游戏模式选择
func _init_game_mode_selection() -> void:
	# 清空现有内容
	for child in game_mode_label.get_parent().get_children():
		if child != game_mode_label and child != confirm_button and child != cancel_button:
			child.queue_free()

	# 创建游戏模式按钮
	var grid_container = HBoxContainer.new()
	grid_container.alignment = BoxContainer.ALIGNMENT_CENTER

	var index = 0
	for mode_id in game_modes:
		var mode_name = game_modes[mode_id]
		var button = Button.new()
		button.text = mode_name
		button.custom_minimum_size = Vector2(120, 40)
		button.pressed.connect(_on_game_mode_selected.bind(mode_id))
		grid_container.add_child(button)

		# 添加分隔符
		if index < len(game_modes) - 1:
			var separator = VSeparator.new()
			grid_container.add_child(separator)

		index += 1

	game_mode_label.get_parent().add_child(grid_container)

## 初始化地图选择
func _init_map_selection() -> void:
	# 清空现有内容
	for child in map_selection_container.get_children():
		child.queue_free()

	# 创建地图按钮
	var grid_container = HBoxContainer.new()
	grid_container.alignment = BoxContainer.ALIGNMENT_CENTER

	var index = 0
	for map_id in map_options:
		var map_name = map_options[map_id]
		var button = Button.new()
		button.text = map_name
		button.custom_minimum_size = Vector2(120, 40)
		button.pressed.connect(_on_map_selected.bind(map_id))
		grid_container.add_child(button)

		# 添加分隔符
		if index < len(map_options) - 1:
			var separator = VSeparator.new()
			grid_container.add_child(separator)

		index += 1

	map_selection_container.add_child(grid_container)

## 初始化阵营选择
func _init_faction_selection() -> void:
	# 清空现有内容
	for child in faction_selection_container.get_children():
		child.queue_free()

	# 创建阵营按钮
	var grid_container = HBoxContainer.new()
	grid_container.alignment = BoxContainer.ALIGNMENT_CENTER

	var index = 0
	for faction_id in faction_options:
		var faction_name = faction_options[faction_id]
		var button = Button.new()
		button.text = faction_name
		button.custom_minimum_size = Vector2(120, 40)
		button.pressed.connect(_on_faction_selected.bind(faction_id))
		grid_container.add_child(button)

		# 添加分隔符
		if index < len(faction_options) - 1:
			var separator = VSeparator.new()
			grid_container.add_child(separator)

		index += 1

	faction_selection_container.add_child(grid_container)

## 显示对话框
func appear_dialog(is_map_selection: bool = false, is_faction_selection: bool = false) -> void:
	self.is_map_selection = is_map_selection
	self.is_faction_selection = is_faction_selection

	# 根据模式显示不同内容
	if is_map_selection:
		title_label.text = "选择地图"
		_init_map_selection()
		map_selection_container.visible = true
		faction_selection_container.visible = false
	elif is_faction_selection:
		title_label.text = "选择阵营"
		_init_faction_selection()
		map_selection_container.visible = false
		faction_selection_container.visible = true
	else:
		title_label.text = "选择游戏模式"
		_init_game_mode_selection()
		map_selection_container.visible = false
		faction_selection_container.visible = false

	dialog_container.visible = true
	SoundManager.play_other_SFX("ui_open")

## 隐藏对话框
func disappear_dialog() -> void:
	dialog_container.visible = false
	SoundManager.play_other_SFX("ui_close")

## 游戏模式选择回调
func _on_game_mode_selected(mode_id: String) -> void:
	current_game_mode = mode_id
	title_label.text = "选择地图"
	_init_map_selection()
	map_selection_container.visible = true
	faction_selection_container.visible = false
	SoundManager.play_other_SFX("ui_click")

## 地图选择回调
func _on_map_selected(map_id: String) -> void:
	current_map = map_id
	title_label.text = "选择阵营"
	_init_faction_selection()
	map_selection_container.visible = false
	faction_selection_container.visible = true
	SoundManager.play_other_SFX("ui_click")

## 阵营选择回调
func _on_faction_selected(faction_id: String) -> void:
	current_faction = faction_id
	disappear_dialog()
	SoundManager.play_other_SFX("ui_confirm")

	# 调用回调函数
	if callback.is_valid():
		callback.call(current_game_mode, current_map, current_faction)

## 确认按钮回调
func _on_confirm_pressed() -> void:
	if is_map_selection:
		current_map = current_map
		title_label.text = "选择阵营"
		_init_faction_selection()
		map_selection_container.visible = false
		faction_selection_container.visible = true
		SoundManager.play_other_SFX("ui_click")
	elif is_faction_selection:
		current_faction = current_faction
		disappear_dialog()
		SoundManager.play_other_SFX("ui_confirm")

		# 调用回调函数
		if callback.is_valid():
			callback.call(current_game_mode, current_map, current_faction)
	else:
		disappear_dialog()
		SoundManager.play_other_SFX("ui_confirm")

		# 调用回调函数
		if callback.is_valid():
			callback.call(current_game_mode, current_map, current_faction)

## 取消按钮回调
func _on_cancel_pressed() -> void:
	disappear_dialog()
	SoundManager.play_other_SFX("ui_cancel")

## 设置回调函数
func set_callback(callback_func: Callable) -> void:
	callback = callback_func

## 清理
func cleanup() -> void:
	if dialog_container:
		dialog_container.visible = false

	print("[NetworkGameSetupDialog] 已清理网络游戏设置对话框")
