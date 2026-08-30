# PVZ-Godot 联机功能集成指南

## 快速开始

### 1. 添加NetworkManager

1. 在Godot编辑器中打开项目
2. 进入项目设置 → 自动加载
3. 点击"添加"按钮
4. 选择 `scripts/autoload/network/network_manager.gd`
5. 设置名称为 `NetworkManager`
6. 点击"应用"

### 2. 修改Global.gd

在 `scripts/autoload/global/global.gd` 中添加以下代码：

```gdscript
## 网络管理器
@onready var network_manager: NetworkManager = %NetworkManager

## 网络游戏初始化
func init_network_game(mode: String, map_name: String, faction_name: String) -> void:
	if network_manager == null:
		push_error("[Global] NetworkManager未找到")
		return

	# 设置游戏参数
	network_game_mode = mode
	network_selected_map = map_name
	network_selected_faction = faction_name

	# 创建网络游戏状态
	var network_state = NetworkGameState.create_new(mode, map_name, faction_name)

	# 如果是主机，创建主机
	if network_manager.is_host_player():
		network_manager.create_host(25565, 4)

	# 如果是客户端，连接到主机
	if network_manager.is_client_player():
		network_manager.connect_to_host("localhost", 25565)

	# 发送玩家信息
	network_manager.send_player_info()

	print("[Global] 网络游戏初始化完成")
```

### 3. 修改主游戏管理器

在 `scripts/manager/main_game_manager.gd` 中添加：

```gdscript
## 网络功能
@export var is_network_game: bool = false
var network_manager: NetworkManager
var local_player_id: int = 0

func _init_network_game() -> void:
	network_manager = get_node("/root/NetworkManager")
	if network_manager == null:
		push_error("[MainGameManager] NetworkManager未找到")
		return

	local_player_id = network_manager.get_local_player_id()
	print("[MainGameManager] 网络游戏初始化完成，本地玩家ID: %d" % local_player_id)
```

在 `_ready()` 函数中添加网络初始化：

```gdscript
func _ready() -> void:
	# 网络游戏初始化
	if is_network_game:
		_init_network_game()

	# ... 其他初始化代码
```

### 4. 在开始菜单添加联机按钮

在 `scripts/ui/start_menu/start_menu_root.gd` 中添加：

```gdscript
## 联机模式
func _on_network_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/network_menu.tscn")
```

### 5. 在网络菜单中处理游戏开始

在 `scripts/ui/network_menu.gd` 中修改 `_on_start_pressed()` 函数：

```gdscript
func _on_start_pressed() -> void:
	if all_players_ready():
		# 调用Global初始化网络游戏
		Global.init_network_game(current_game_mode, current_map, current_faction)
		# 等待网络初始化完成
		await get_tree().create_timer(1.0).timeout
		# 开始游戏
		get_tree().change_scene_to_file(Global.main_scene_registry.MainScenesMap[MainSceneRegistry.MainScenes.MainGame])
```

## 验证安装

1. 运行游戏
2. 在开始菜单中应该能看到联机模式按钮
3. 点击联机模式按钮，应该能看到联机菜单
4. 点击"创建主机"按钮，应该看到连接状态变为"主机"

## 下一步

- 阅读 `docs/NETWORK_FEATURE.md` 了解功能详情
- 阅读 `docs/NETWORK_EXAMPLES.md` 了解使用示例
- 阅读 `docs/NETWORK_CONFIGURATION.md` 了解配置指南
- 阅读 `docs/NETWORK_SUMMARY.md` 了解架构设计

## 故障排查

### 问题1: NetworkManager未找到

**解决方案**: 确保NetworkManager已添加到自动加载列表

### 问题2: 无法连接到主机

**解决方案**:
- 检查主机IP是否正确
- 检查端口是否正确
- 检查防火墙设置
- 确保主机已启动

### 问题3: UI不显示

**解决方案**:
- 检查场景是否正确加载
- 检查UI节点是否正确配置
- 查看控制台是否有错误信息

## 常见任务

### 添加新的游戏模式

1. 在 `scripts/ui/network_game_setup_dialog.gd` 中添加新模式选项
2. 在 `game_modes` 字典中添加新模式
3. 在 `main_game_manager.gd` 中处理新模式逻辑

### 添加新的地图

1. 在 `scripts/ui/network_game_setup_dialog.gd` 中添加新地图选项
2. 在 `map_options` 字典中添加新地图
3. 在 `const_level_data.gd` 中添加地图配置

### 添加新的阵营

1. 在 `scripts/ui/network_game_setup_dialog.gd` 中添加新阵营选项
2. 在 `faction_options` 字典中添加新阵营
3. 在游戏逻辑中使用阵营信息

## 获取帮助

- 查看文档: `docs/` 目录
- 查看示例: `docs/NETWORK_EXAMPLES.md`
- 查看配置: `docs/NETWORK_CONFIGURATION.md`
- 查看总结: `docs/NETWORK_SUMMARY.md`

## 更新日志

### v1.0.0 (2026-07-18)
- 初始版本发布
- 基本主机-客户端架构
- 支持4名玩家
- 游戏设置功能
- 状态同步系统

## 许可证

与主项目许可证相同。

## 故障排查

### 问题1: NetworkManager未找到

**解决方案**: 确保NetworkManager已添加到自动加载列表

### 问题2: 无法连接到主机

**解决方案**:
- 检查主机IP是否正确
- 检查端口是否正确
- 检查防火墙设置
- 确保主机已启动

### 问题3: UI不显示

**解决方案**:
- 检查场景是否正确加载
- 检查UI节点是否正确配置
- 查看控制台是否有错误信息

## 常见任务

### 添加新的游戏模式

1. 在 `scripts/ui/network_game_setup_dialog.gd` 中添加新模式选项
2. 在 `game_modes` 字典中添加新模式
3. 在 `main_game_manager.gd` 中处理新模式逻辑

### 添加新的地图

1. 在 `scripts/ui/network_game_setup_dialog.gd` 中添加新地图选项
2. 在 `map_options` 字典中添加新地图
3. 在 `const_level_data.gd` 中添加地图配置

### 添加新的阵营

1. 在 `scripts/ui/network_game_setup_dialog.gd` 中添加新阵营选项
2. 在 `faction_options` 字典中添加新阵营
3. 在游戏逻辑中使用阵营信息

## 获取帮助

- 查看文档: `docs/` 目录
- 查看示例: `docs/NETWORK_EXAMPLES.md`
- 查看配置: `docs/NETWORK_CONFIGURATION.md`
- 查看总结: `docs/NETWORK_SUMMARY.md`

## 更新日志

### v1.0.0 (2026-07-18)
- 初始版本发布
- 基本主机-客户端架构
- 支持4名玩家
- 游戏设置功能
- 状态同步系统

## 许可证

与主项目许可证相同。
