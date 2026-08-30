extends Node

## 游戏暂停因素
enum E_PauseFactor {
	Menu,			## 菜单
	GameOver,		## 游戏结束
	ReChooseCard,	## 重新选卡
	AdvancedPause,	## 高级暂停（控制台）
}

var curr_pause_factor: Dictionary = {}

## 高级暂停状态
var is_advanced_paused := false:
	set(value):
		if is_advanced_paused == value:
			return
		is_advanced_paused = value
		signal_advanced_pause_changed.emit(is_advanced_paused)

## 高级暂停状态变化信号
signal signal_advanced_pause_changed(pause: bool)

func _ready() -> void:
	## 暂停时仍需接收输入（高级暂停空格恢复）
	process_mode = Node.PROCESS_MODE_ALWAYS

func _update_pause_state() -> void:
	get_tree().paused = curr_pause_factor.values().any(func(v): return v)
	if get_tree().paused:
		print("暂停游戏")
	else:
		print("继续游戏")

## 开始场景树暂停
func start_tree_pause(pause_factor: E_PauseFactor) -> void:
	curr_pause_factor[pause_factor] = true
	_update_pause_state()

## 结束场景树暂停
func end_tree_pause(pause_factor: E_PauseFactor) -> void:
	curr_pause_factor[pause_factor] = false
	_update_pause_state()

## 清除所有暂停因素
func end_tree_pause_clear_all_pause_factors() -> void:
	curr_pause_factor.clear()
	is_advanced_paused = false
	_update_pause_state()

## 开始高级暂停（控制台选项：暂停游戏，不显示暂停窗口，可交互，空格恢复）
func start_advanced_pause() -> void:
	is_advanced_paused = true
	start_tree_pause(E_PauseFactor.AdvancedPause)
	_set_advanced_pause_process_mode(true)

## 结束高级暂停
func end_advanced_pause() -> void:
	is_advanced_paused = false
	end_tree_pause(E_PauseFactor.AdvancedPause)
	_set_advanced_pause_process_mode(false)

## 切换高级暂停
func toggle_advanced_pause() -> void:
	if is_advanced_paused:
		end_advanced_pause()
	else:
		start_advanced_pause()

## 高级暂停时：设置允许交互的节点保持 PROCESS_MODE_ALWAYS
func _set_advanced_pause_process_mode(active: bool) -> void:
	var mode := Node.PROCESS_MODE_ALWAYS if active else Node.PROCESS_MODE_INHERIT
	if Global.main_game == null:
		return
	# 卡槽根节点（快捷键选卡、铲子）
	var csr = Global.main_game.card_slot_root
	if csr != null and is_instance_valid(csr):
		csr.process_mode = mode
	# 手持管理器（种植、铲除交互）
	var hm = Global.main_game.hand_manager
	if hm != null and is_instance_valid(hm):
		hm.process_mode = mode
	# 植物格子根节点（Button鼠标点击/进入/退出需要接收输入）
	var pcr = Global.main_game.plant_cell_manager.plant_cells_root
	if pcr != null and is_instance_valid(pcr):
		pcr.process_mode = mode

## 空格键触发/恢复高级暂停（需先在控制台启用）
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("AdvancedPause") and Global.config_service.advanced_pause:
		if is_advanced_paused:
			end_advanced_pause()
		else:
			start_advanced_pause()
		get_viewport().set_input_as_handled()
