# 网络功能使用示例

## 基本使用

### 在开始菜单添加联机按钮

```gdscript
# 在 start_menu_root.gd 中添加

## 联机模式
func _on_network_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/network_menu.tscn")
```

### 在网络菜单中处理游戏开始

```gdscript
# 在 network_menu.gd 中修改游戏开始逻辑

func _on_start_pressed() -> void:
	if all_players_ready():
		# 调用Global初始化网络游戏
		Global.init_network_game(current_game_mode, current_map, current_faction)
		# 等待网络初始化完成
		await get_tree().create_timer(1.0).timeout
		# 开始游戏
		get_tree().change_scene_to_file(Global.main_scene_registry.MainScenesMap[MainSceneRegistry.MainScenes.MainGameFront])
```

## 高级使用

### 在主游戏管理器中处理网络事件

```gdscript
# 在 main_game_manager.gd 中添加

func _on_network_game_started() -> void:
	network_game_started = true
	# 应用网络设置到游戏参数
	game_para.game_mode = network_game_mode
	# 设置地图
	game_para.game_BG = _get_bg_from_map(network_selected_map)
	# 设置阵营
	_apply_faction(network_selected_faction)
	# 开始游戏
	main_game_start()

func _get_bg_from_map(map_name: String) -> ConstLevelData.GameBg:
	match map_name:
		"day": return ConstLevelData.GameBg.FrontDay
		"night": return ConstLevelData.GameBg.FrontNight
		"pool": return ConstLevelData.GameBg.Pool
		"fog": return ConstLevelData.GameBg.Fog
		"roof": return ConstLevelData.GameBg.Roof
	return ConstLevelData.GameBg.FrontDay

func _apply_faction(faction_name: String) -> void:
	match faction_name:
		"plants": apply_plants_faction()
		"zombies": apply_zombies_faction()
		"mixed": apply_mixed_faction()
```

### 在主游戏管理器中添加网络同步

```gdscript
# 在 main_game_manager.gd 中添加

func sync_game_state() -> void:
	if not is_network_game:
		return

	# 同步游戏参数
	var sync_data = {
		"type": "game_state_update",
		"game_mode": game_para.game_mode,
		"selected_map": network_selected_map,
		"selected_faction": network_selected_faction,
		"main_game_progress": main_game_progress
	}
	network_manager.broadcast_data(sync_data)

# 在关键游戏事件中调用
func on_plant_placed(plant: Plant) -> void:
	sync_game_state()

func on_zombie_spawned(zombie: Zombie) -> void:
	sync_game_state()
```

## 自定义网络功能

### 添加自定义消息类型

```gdscript
# 在 network_manager.gd 中添加

## 发送自定义消息
func send_custom_message(message_type: String, data: Dictionary) -> void:
	var message = {
		"type": "custom",
		"message_type": message_type,
		"data": data
	}
	broadcast_data(message)

## 处理自定义消息
func _on_custom_message_received(data: Dictionary) -> void:
	var message_type = data.get("message_type", "")
	var custom_data = data.get("data", {})

	match message_type:
		"player_action":
			_on_player_action(custom_data)
		"game_event":
			_on_game_event(custom_data)
```

### 实现玩家动作同步

```gdscript
func _on_player_action(data: Dictionary) -> void:
	var player_id = data.get("player_id")
	var action_type = data.get("action_type")
	var action_data = data.get("data", {})

	match action_type:
		"place_plant":
			_sync_player_place_plant(player_id, action_data)
		"use_ability":
			_sync_player_use_ability(player_id, action_data)

func _sync_player_place_plant(player_id: int, data: Dictionary) -> void:
	# 应用其他玩家的植物放置
	var plant_data = data.get("plant_data")
	# 在对应位置创建植物
	# ...

func _sync_player_use_ability(player_id: int, data: Dictionary) -> void:
	var ability_type = data.get("ability_type")
	# 应用其他玩家的技能使用
	# ...
```

## 网络同步优化

### 使用增量更新

```gdscript
func sync_game_state_incremental() -> void:
	if not is_network_game:
		return

	# 只同步变化的数据
	var changed_data = get_changed_data()
	if not changed_data.is_empty():
		network_manager.broadcast_data({
			"type": "game_state_update",
			"changed_data": changed_data
		})
```

### 使用状态压缩

```gdscript
func compress_state(state_data: Dictionary) -> Dictionary:
	# 简化数据结构
	var compressed = {}
	for key in state_data:
		if typeof(state_data[key]) in [int, float, bool, String]:
			compressed[key] = state_data[key]
		else:
			# 复杂数据只发送ID
			compressed[key] = state_data[key].get("id", "")
	return compressed
```

## 网络安全

### 验证玩家身份

```gdscript
func verify_player_identity(player_id: int, expected_id: int) -> bool:
	return player_id == expected_id
```

### 限制玩家操作

```gdscript
func can_player_perform_action(player_id: int, action_type: String) -> bool:
	# 检查玩家是否为主机
	if not network_manager.is_host_player():
		return false

	# 检查玩家是否在游戏中
	if not is_player_in_game(player_id):
		return false

	return true
```

## 测试

### 本地测试

```gdscript
# 在network_menu.gd中添加测试按钮

func _on_test_button_pressed() -> void:
	# 测试主机创建
	network_manager.create_host(25565)

	# 测试客户端连接
	network_manager.connect_to_host("localhost", 25565)

	# 测试数据传输
	network_manager.broadcast_data({"type": "test_message", "value": "test"})

	# 测试网络延迟
	print("网络延迟: %d ms" % network_manager.get_network_latency())
```

### 网络测试

1. 运行主机实例
2. 运行1-3个客户端实例
3. 测试连接、游戏开始、状态同步等功能
4. 检查网络延迟和稳定性
5. 测试断线重连

## 故障排查

### 连接问题

```gdscript
# 在网络菜单中添加连接测试

func _test_connection(ip: String, port: int) -> bool:
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(ip, port)

	if err == OK:
		peer.disconnect_from_host()
		return true
	else:
		return false
```

### 同步问题

```gdscript
# 在主游戏管理器中添加同步测试

func _test_sync() -> void:
	if is_network_game:
		print("当前游戏状态:")
		print("游戏模式: %s" % game_para.game_mode)
		print("地图: %s" % network_selected_map)
		print("阵营: %s" % network_selected_faction)
		print("玩家数量: %d" % network_manager.get_player_count())
```

## 更多示例

参考以下文件获取更多实现细节：

- `scripts/autoload/network/network_manager.gd` - 网络管理器实现
- `scripts/ui/network_menu.gd` - 网络菜单实现
- `scripts/manager/main_game_manager.gd` - 主游戏管理器集成
