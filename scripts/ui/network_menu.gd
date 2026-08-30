extends Control
class_name NetworkMenu

## 联机菜单

## BGM
var bgm: AudioStream

@onready var back_button: Button = $VBoxContainer/BackButton
@onready var host_button: Button = $VBoxContainer/ButtonsContainer/HostButton
@onready var client_button: Button = $VBoxContainer/ButtonsContainer/ClientButton
@onready var host_ip_input: LineEdit = $VBoxContainer/IPContainer/HostIPInput
@onready var port_input: LineEdit = $VBoxContainer/IPContainer/PortInput
@onready var connection_status_label: Label = $VBoxContainer/ConnectionStatusLabel
@onready var player_count_label: Label = $VBoxContainer/PlayerCountLabel
@onready var game_mode_label: Label = $VBoxContainer/GameInfoContainer/GameModeLabel
@onready var map_label: Label = $VBoxContainer/GameInfoContainer/MapLabel
@onready var faction_label: Label = $VBoxContainer/GameInfoContainer/FactionLabel
@onready var ready_button: Button = $VBoxContainer/ReadyButton
@onready var start_button: Button = $VBoxContainer/StartButton
@onready var player_list: VBoxContainer = $VBoxContainer/PlayerList

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

## 本地玩家ID
var local_player_id: int = 0

## 是否已就绪
var is_ready: bool = false

## 是否为主机
var is_host: bool = false

## 网络管理器
var network_manager: NetworkManager

## 初始化网络菜单
func _ready() -> void:
	print("[NetworkMenu] 初始化开始")
	print("[NetworkMenu] 节点名称: %s" % name)

	# 获取网络管理器
	network_manager = get_node("/root/NetworkManager")
	print("[NetworkMenu] NetworkManager: %s" % network_manager)

	if network_manager == null:
		push_error("[NetworkMenu] NetworkManager 未找到，请确保在项目设置的自动加载中添加 NetworkManager")
		queue_free()
		return

	print("[NetworkMenu] NetworkManager 找到，连接状态: %s" % network_manager.get_connection_status_text())

	# 设置默认端口
	port_input.text = "25565"

	# 初始化UI
	update_connection_status()
	update_player_count()
	update_game_info()
	update_player_list()

	# 连接网络管理器信号
	network_manager.connection_status_changed.connect(_on_connection_status_changed)
	network_manager.player_joined.connect(_on_player_joined)
	network_manager.player_left.connect(_on_player_left)
	network_manager.map_selected.connect(_on_map_selected)
	network_manager.faction_selected.connect(_on_faction_selected)
	network_manager.game_started.connect(_on_game_started)

	# 设置按钮连接
	back_button.pressed.connect(_on_back_pressed)
	host_button.pressed.connect(_on_host_pressed)
	client_button.pressed.connect(_on_client_pressed)
	ready_button.pressed.connect(_on_ready_pressed)
	start_button.pressed.connect(_on_start_pressed)

	# 更新按钮状态
	update_button_states()

	# 播放BGM
	if bgm:
		SoundManager.play_bgm(bgm)

	print("[NetworkMenu] 初始化完成")

## 更新连接状态
func update_connection_status() -> void:
	if network_manager == null:
		return

	var status_text = network_manager.get_connection_status_text()
	var status_color = Color.WHITE

	match network_manager.connection_status:
		NetworkManager.E_ConnectionStatus.Disconnected:
			status_color = Color.RED
			if host_button != null:
				host_button.disabled = false
			if client_button != null:
				client_button.disabled = false
		NetworkManager.E_ConnectionStatus.Connecting:
			status_color = Color.YELLOW
			if host_button != null:
				host_button.disabled = true
			if client_button != null:
				client_button.disabled = true
		NetworkManager.E_ConnectionStatus.Host:
			status_color = Color.GREEN
			if host_button != null:
				host_button.disabled = true
			if client_button != null:
				client_button.disabled = true
			is_host = true
		NetworkManager.E_ConnectionStatus.Client:
			status_color = Color.GREEN
			if host_button != null:
				host_button.disabled = true
			if client_button != null:
				client_button.disabled = true
			is_host = false

	connection_status_label.text = "连接状态: %s" % status_text
	connection_status_label.add_theme_color_override("font_color", status_color)

## 更新玩家数量
func update_player_count() -> void:
	if network_manager == null:
		return

	var count = network_manager.get_player_count()
	player_count_label.text = "玩家数量: %d / 4" % count

## 更新游戏信息
func update_game_info() -> void:
	game_mode_label.text = "游戏模式: %s" % game_modes.get(current_game_mode, current_game_mode)
	map_label.text = "地图: %s" % map_options.get(current_map, current_map)
	faction_label.text = "阵营: %s" % faction_options.get(current_faction, current_faction)

## 更新玩家列表
func update_player_list() -> void:
	print("[NetworkMenu] update_player_list 调用")
	# 清空现有列表
	for child in player_list.get_children():
		child.queue_free()

	# 添加玩家
	if network_manager == null:
		print("[NetworkMenu] network_manager 为 null")
		return

	var players = network_manager.get_all_players()
	print("[NetworkMenu] 玩家列表: %s" % players)
	for player_id in players:
		var player_info = players[player_id]
		var is_ready = player_info.get("ready", false)
		var player_name = player_info.get("name", "Unknown")
		var is_local = (player_id == local_player_id)

		print("[NetworkMenu] 添加玩家: %s (ID: %d, 准备: %s, 本地: %s)" % [player_name, player_id, is_ready, is_local])

		var player_row = HBoxContainer.new()
		player_row.alignment = BoxContainer.ALIGNMENT_CENTER

		var player_name_label = Label.new()
		player_name_label.text = player_name
		player_name_label.add_theme_font_size_override("font_size", 14)

		var ready_status_label = Label.new()
		ready_status_label.text = "已就绪" if is_ready else "未准备"
		ready_status_label.add_theme_font_size_override("font_size", 12)
		ready_status_label.add_theme_color_override("font_color", Color.GREEN if is_ready else Color.RED)

		player_row.add_child(player_name_label)
		player_row.add_child(ready_status_label)

		if is_local:
			player_row.add_child(Label.new())

		player_list.add_child(player_row)

## 更新按钮状态
func update_button_states() -> void:
	print("[NetworkMenu] update_button_states 调用")
	if network_manager == null:
		return

	# 检查按钮是否已初始化
	if ready_button != null:
		ready_button.text = "准备" if not is_ready else "取消准备"
		var should_disable = network_manager.connection_status != NetworkManager.E_ConnectionStatus.Host and network_manager.connection_status != NetworkManager.E_ConnectionStatus.Client
		ready_button.disabled = should_disable
		print("[NetworkMenu] ready_button 文本: %s" % ready_button.text)
		print("[NetworkMenu] ready_button 禁用状态: %s" % ready_button.disabled)
		print("[NetworkMenu] 连接状态: %s" % network_manager.get_connection_status_text())
		print("[NetworkMenu] is_host_player: %s" % network_manager.is_host_player())
		print("[NetworkMenu] is_ready: %s" % is_ready)

	if start_button != null:
		start_button.disabled = not network_manager.is_host_player() or not all_players_ready()
		print("[NetworkMenu] start_button 禁用状态: %s" % start_button.disabled)
		print("[NetworkMenu] all_players_ready: %s" % all_players_ready())

## 检查所有玩家是否就绪
func all_players_ready() -> bool:
	if network_manager == null:
		return false

	if network_manager.get_player_count() == 0:
		return false

	var players = network_manager.get_all_players()
	for player_id in players:
		if not players[player_id].get("ready", false):
			return false

	return true

## 更新准备状态
func update_ready_status() -> void:
	print("[NetworkMenu] update_ready_status 调用")
	if network_manager == null:
		print("[NetworkMenu] network_manager 为 null")
		return

	# 客户端模式下，直接检查本地玩家是否准备
	if not network_manager.is_host_player():
		is_ready = network_manager.is_player_ready(local_player_id)
	else:
		# 主机模式下，检查本地玩家是否准备
		is_ready = network_manager.is_player_ready(local_player_id)

	print("[NetworkMenu] 更新后的 is_ready: %s" % is_ready)
	print("[NetworkMenu] is_host_player: %s" % network_manager.is_host_player())
	print("[NetworkMenu] is_player_ready: %s" % network_manager.is_player_ready(local_player_id))
	print("[NetworkMenu] 玩家列表: %s" % network_manager.get_all_players())
	update_button_states()
	update_player_list()

## 网络管理器信号回调

func _on_connection_status_changed(status: NetworkManager.E_ConnectionStatus) -> void:
	update_connection_status()
	update_player_count()

func _on_player_joined(player_id: int, player_name: String) -> void:
	update_player_list()
	update_player_count()

func _on_player_left(player_id: int) -> void:
	update_player_list()
	update_player_count()

func _on_map_selected(map_name: String) -> void:
	current_map = map_name
	update_game_info()

func _on_faction_selected(faction_name: String) -> void:
	current_faction = faction_name
	update_game_info()

func _on_game_started() -> void:
	print("[NetworkMenu] 游戏开始！")
	get_tree().change_scene_to_file(Global.main_scene_registry.MainScenesMap[MainSceneRegistry.MainScenes.MainGameFront])

## 按钮回调

func _on_back_pressed() -> void:
	print("[NetworkMenu] 返回按钮点击")
	get_tree().quit()

func _on_host_pressed() -> void:
	print("[NetworkMenu] 创建主机按钮点击")
	var port = int(port_input.text)
	network_manager.create_host(port)
	# 设置本地玩家ID
	local_player_id = network_manager.get_local_player_id()
	# 初始化玩家准备状态
	network_manager.set_player_ready(local_player_id, false)
	if ready_button != null:
		ready_button.disabled = false
	update_button_states()

func _on_client_pressed() -> void:
	print("[NetworkMenu] 加入游戏按钮点击")
	var ip = host_ip_input.text
	var port = int(port_input.text)
	network_manager.connect_to_host(ip, port)
	# 设置本地玩家ID
	local_player_id = network_manager.get_local_player_id()
	# 初始化玩家准备状态
	network_manager.set_player_ready(local_player_id, false)
	if ready_button != null:
		ready_button.disabled = false
	update_button_states()

func _on_ready_pressed() -> void:
	print("[NetworkMenu] 准备按钮点击")
	print("[NetworkMenu] ready_button.text: %s" % ready_button.text if ready_button else "ready_button 为 null")
	print("[NetworkMenu] ready_button.disabled: %s" % (ready_button.disabled if ready_button else "ready_button 为 null"))
	print("[NetworkMenu] network_manager.is_host_player: %s" % network_manager.is_host_player())
	print("[NetworkMenu] network_manager.connection_status: %s" % network_manager.connection_status)
	print("[NetworkMenu] is_ready: %s" % is_ready)
	print("[NetworkMenu] local_player_id: %d" % local_player_id)
	print("[NetworkMenu] 玩家列表: %s" % network_manager.get_all_players())

	if network_manager.is_host_player():
		is_ready = not is_ready
		print("[NetworkMenu] 主机模式，切换准备状态: %s" % is_ready)
		network_manager.set_player_ready(local_player_id, is_ready)
		print("[NetworkMenu] 玩家列表: %s" % network_manager.get_all_players())
		update_ready_status()
		update_player_list()
	else:
		print("[NetworkMenu] 客户端模式，通知准备状态")
		network_manager.player_ready()
		is_ready = true
		update_ready_status()
		update_player_list()

func _on_start_pressed() -> void:
	print("[NetworkMenu] 开始游戏按钮点击")
	if all_players_ready():
		# 调用Global初始化网络游戏
		Global.init_network_game(current_game_mode, current_map, current_faction)
		# 等待网络初始化完成
		await get_tree().create_timer(1.0).timeout
		# 开始游戏
		get_tree().change_scene_to_file(Global.main_scene_registry.MainScenesMap[MainSceneRegistry.MainScenes.MainGameFront])

## 键盘事件处理
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_back_pressed()

## 清理
func cleanup() -> void:
	if network_manager:
		network_manager.connection_status_changed.disconnect(_on_connection_status_changed)
		network_manager.player_joined.disconnect(_on_player_joined)
		network_manager.player_left.disconnect(_on_player_left)
		network_manager.map_selected.disconnect(_on_map_selected)
		network_manager.faction_selected.disconnect(_on_faction_selected)
		network_manager.game_started.disconnect(_on_game_started)

	print("[NetworkMenu] 已清理网络菜单")
