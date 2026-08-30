extends Node
class_name NetworkManagerInstance

## 网络连接状态
enum E_ConnectionStatus {
	Disconnected,
	Connecting,
	Host,
	Client
}

## 网络管理器单例
var network_manager: NetworkManagerInstance = self

## 网络连接状态
var connection_status: E_ConnectionStatus = E_ConnectionStatus.Disconnected

## 是否为主机
var is_host: bool = false

## 客户端列表
var clients: Dictionary = {}

## 当前游戏模式
var game_mode: String = ""

## 地图选择
var selected_map: String = ""

## 阵营选择
var selected_faction: String = ""

## 信号：网络连接状态改变
signal connection_status_changed(status: E_ConnectionStatus)

## 信号：游戏开始
signal game_started()

## 信号：玩家加入
signal player_joined(player_id: int, player_name: String)

## 信号：玩家离开
signal player_left(player_id: int)

## 信号：地图选择更新
signal map_selected(map_name: String)

## 信号：阵营选择更新
signal faction_selected(faction_name: String)

#region 网络初始化

## 初始化网络管理器
func _ready() -> void:
	add_to_group("network_manager")
	print("[NetworkManager] 初始化完成")

#region 主机功能

## 创建主机
func create_host(port: int = 25565, max_players: int = 4) -> void:
	if connection_status != E_ConnectionStatus.Disconnected:
		push_error("[NetworkManager] 已经在连接或已连接状态，无法创建主机")
		return

	is_host = true
	connection_status = E_ConnectionStatus.Connecting

	print("[NetworkManager] 正在创建主机，端口: %d, 最大玩家数: %d" % [port, max_players])

	# 启动网络服务器
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(port, max_players)

	if err != OK:
		connection_status = E_ConnectionStatus.Disconnected
		push_error("[NetworkManager] 创建主机失败，错误代码: %d" % err)
		return

	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)

	multiplayer.multiplayer_peer = peer
	connection_status = E_ConnectionStatus.Host

	print("[NetworkManager] 主机创建成功，监听端口: %d" % port)

#region 客户端功能

## 连接到主机
func connect_to_host(ip: String, port: int = 25565) -> void:
	if connection_status != E_ConnectionStatus.Disconnected:
		push_error("[NetworkManager] 已经在连接或已连接状态，无法连接主机")
		return

	is_host = false
	connection_status = E_ConnectionStatus.Connecting

	print("[NetworkManager] 正在连接到主机: %s:%d" % [ip, port])

	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)

	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(ip, port)

	if err != OK:
		connection_status = E_ConnectionStatus.Disconnected
		push_error("[NetworkManager] 连接主机失败，错误代码: %d" % err)
		return

	multiplayer.multiplayer_peer = peer

#region 网络通信

## 发送数据到指定玩家
func send_to_player(player_id: int, data: Dictionary) -> void:
	if multiplayer.has_multiplayer_peer():
		rpc_id(player_id, "receive_data", data)

## 广播数据给所有玩家
func broadcast_data(data: Dictionary) -> void:
	if multiplayer.has_multiplayer_peer():
		rpc("receive_data", data)

## 发送数据到所有其他玩家（不包括自己）
func send_to_others(data: Dictionary) -> void:
	if multiplayer.has_multiplayer_peer():
		rpc_id(1, "receive_data", data) if is_host else rpc("receive_data", data)

## 接收网络数据
func receive_data(data: Dictionary) -> void:
	print("[NetworkManager] 收到数据: %s" % data)

	# 根据数据类型处理
	match data.get("type", ""):
		"map_selection":
			selected_map = data.get("value", "")
			emit_signal("map_selected", selected_map)
		"faction_selection":
			selected_faction = data.get("value", "")
			emit_signal("faction_selected", selected_faction)
		"player_ready":
			var sender_id = multiplayer.get_remote_sender_id()
			print("[NetworkManager] 玩家 %d 已就绪" % sender_id)
			# 更新玩家准备状态
			if clients.has(sender_id):
				clients[sender_id]["ready"] = true

## 设置游戏模式
func set_game_mode(mode: String) -> void:
	game_mode = mode
	broadcast_data({"type": "game_mode_update", "value": mode})

## 选择地图
func select_map(map_name: String) -> void:
	selected_map = map_name
	broadcast_data({"type": "map_selection", "value": map_name})
	emit_signal("map_selected", map_name)

## 选择阵营
func select_faction(faction_name: String) -> void:
	selected_faction = faction_name
	broadcast_data({"type": "faction_selection", "value": faction_name})
	emit_signal("faction_selected", faction_name)

## 玩家准备就绪
func player_ready() -> void:
	var sender_id = multiplayer.get_remote_sender_id()
	broadcast_data({"type": "player_ready", "player_id": sender_id})

## 请求游戏开始
func request_game_start() -> void:
	if not is_host:
		push_error("[NetworkManager] 只有主机可以请求游戏开始")
		return

	# 检查所有玩家是否准备就绪
	if not all_players_ready():
		print("[NetworkManager] 并非所有玩家都已准备就绪，无法开始游戏")
		return

	print("[NetworkManager] 所有玩家准备就绪，开始游戏")
	broadcast_data({"type": "game_start"})

## 检查所有玩家是否准备就绪
func all_players_ready() -> bool:
	print("[NetworkManager] all_players_ready 检查开始, 玩家列表: %s" % clients)

	# 如果没有玩家，返回 false
	if clients.is_empty():
		print("[NetworkManager] all_players_ready: 没有玩家")
		return false

	# 检查所有玩家是否准备就绪
	for player_id in clients:
		if not clients[player_id].get("ready", false):
			print("[NetworkManager] all_players_ready: 玩家 %d 未准备" % player_id)
			return false

	print("[NetworkManager] all_players_ready: 所有玩家已准备")
	return true

## 开始游戏
func start_game() -> void:
	emit_signal("game_started")

#region 网络事件处理

## 玩家连接
func _on_player_connected(peer_id: int) -> void:
	print("[NetworkManager] 玩家 %d 已连接" % peer_id)

	clients[peer_id] = {
		"peer_id": peer_id,
		"name": "Player_%d" % peer_id,
		"ready": false,
		"faction": ""
	}

	emit_signal("player_joined", peer_id, clients[peer_id]["name"])

	# 如果是主机，广播当前准备状态给新玩家
	if is_host:
		broadcast_data({"type": "player_ready", "player_id": peer_id})
		send_current_game_state(peer_id)

## 玩家断开连接
func _on_player_disconnected(peer_id: int) -> void:
	print("[NetworkManager] 玩家 %d 已断开连接" % peer_id)

	if clients.has(peer_id):
		var player_name = clients[peer_id]["name"]
		clients.erase(peer_id)

		emit_signal("player_left", peer_id)

## 连接到服务器成功
func _on_connected_to_server() -> void:
	print("[NetworkManager] 成功连接到主机")
	connection_status = E_ConnectionStatus.Client

	# 发送玩家信息
	send_player_info()

	# 发送准备状态
	broadcast_data({"type": "player_ready", "player_id": multiplayer.get_unique_id()})

## 连接失败
func _on_connection_failed() -> void:
	print("[NetworkManager] 连接主机失败")
	connection_status = E_ConnectionStatus.Disconnected

## 发送玩家信息
func send_player_info() -> void:
	var data = {
		"type": "player_info",
		"player_id": multiplayer.get_unique_id(),
		"player_name": "Player_%d" % multiplayer.get_unique_id()
	}
	broadcast_data(data)

	# 发送准备状态
	broadcast_data({"type": "player_ready", "player_id": multiplayer.get_unique_id()})

## 发送当前游戏状态
func send_current_game_state(target_peer_id: int) -> void:
	var data = {
		"type": "game_state_update",
		"game_mode": game_mode,
		"selected_map": selected_map,
		"selected_faction": selected_faction,
		"players_ready": clients
	}
	send_to_player(target_peer_id, data)

## 获取所有玩家
func get_all_players() -> Dictionary:
	return clients.duplicate()

## 获取玩家数量
func get_player_count() -> int:
	return clients.size()

## 断开连接
func disconnect_from_host() -> void:
	if multiplayer.has_multiplayer_peer():
		multiplayer.multiplayer_peer.disconnect_from_host()
		multiplayer.multiplayer_peer = null

	connection_status = E_ConnectionStatus.Disconnected
	is_host = false
	clients.clear()

	print("[NetworkManager] 已断开连接")

## 获取连接状态描述
func get_connection_status_text() -> String:
	match connection_status:
		E_ConnectionStatus.Disconnected:
			return "未连接"
		E_ConnectionStatus.Connecting:
			return "连接中..."
		E_ConnectionStatus.Host:
			return "主机"
		E_ConnectionStatus.Client:
			return "客户端"
	return "未知"

## 获取本地玩家ID
func get_local_player_id() -> int:
	return multiplayer.get_unique_id()

## 获取主机ID
func get_host_id() -> int:
	return 1 if is_host else 0

## 检查是否为主机
func is_host_player() -> bool:
	return is_host

## 检查是否为客户端
func is_client_player() -> bool:
	return not is_host

## 检查是否为本地玩家
func is_local_player() -> bool:
	return not multiplayer.is_server() or is_host

## 检查玩家是否准备就绪
func is_player_ready(player_id: int) -> bool:
	# 如果玩家不存在，返回 false
	if not clients.has(player_id):
		print("[NetworkManager] is_player_ready: player_id=%d 不存在" % player_id)
		return false

	var ready = clients[player_id].get("ready", false)
	print("[NetworkManager] is_player_ready: player_id=%d, ready=%s" % [player_id, ready])
	return ready

## 获取网络延迟（毫秒）
func get_network_latency() -> int:
	if not multiplayer.has_multiplayer_peer():
		return 0
	return multiplayer.get_network_latency()

## 获取网络平均延迟（毫秒）
func get_network_average_latency() -> int:
	if not multiplayer.has_multiplayer_peer():
		return 0
	return int(multiplayer.get_network_stats().get("average_time", 0))

## 设置玩家准备状态
func set_player_ready(player_id: int, ready: bool) -> void:
	print("[NetworkManager] set_player_ready 调用: player_id=%d, ready=%s" % [player_id, ready])

	# 如果玩家不存在，先创建玩家信息
	if not clients.has(player_id):
		clients[player_id] = {
			"peer_id": player_id,
			"name": "Player_%d" % player_id,
			"ready": false,
			"faction": ""
		}
		print("[NetworkManager] 创建玩家信息: %s" % player_id)

	clients[player_id]["ready"] = ready
	print("[NetworkManager] 玩家 %d 准备状态已设置: %s, 当前玩家列表: %s" % [player_id, ready, clients])

	# 如果是主机，广播准备状态
	if is_host:
		broadcast_data({"type": "player_ready", "player_id": player_id})

## 清理网络管理器
func cleanup() -> void:
	if multiplayer.has_multiplayer_peer():
		multiplayer.multiplayer_peer = null

	clients.clear()
	connection_status = E_ConnectionStatus.Disconnected

	print("[NetworkManager] 已清理网络管理器")

## 调试信息
func print_debug_info() -> void:
	print("=== NetworkManager Debug Info ===")
	print("状态: %s" % get_connection_status_text())
	print("主机: %s" % ["是" if is_host else "否"])
	print("玩家数量: %d" % get_player_count())
	print("本地玩家ID: %d" % get_local_player_id())
	print("网络延迟: %d ms" % get_network_latency())
	print("游戏模式: %s" % game_mode)
	print("地图: %s" % selected_map)
	print("阵营: %s" % selected_faction)
	print("===============================")
