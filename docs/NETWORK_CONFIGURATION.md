# 网络功能配置指南

## 配置步骤

### 1. 添加NetworkManager自动加载

1. 在Godot编辑器中，打开项目设置
2. 进入"自动加载"选项卡
3. 点击"添加"按钮
4. 选择 `scripts/autoload/network/network_manager.gd`
5. 确保"启用"复选框被选中
6. 设置名称为 `NetworkManager`
7. 点击"应用"

### 2. 修改Global.gd

在 `scripts/autoload/global/global.gd` 中添加：

```gdscript
## 网络管理器
@onready var network_manager: NetworkManager = %NetworkManager
```

### 3. 创建NetworkManager场景

1. 创建新的Node2D场景
2. 添加 `NetworkManager` 脚本
3. 保存场景为 `res://scenes/autoload/network_manager.tscn`
4. 在项目设置中设置为自动加载场景

### 4. 添加网络菜单场景

1. 创建新的Control场景
2. 添加 `NetworkMenu` 脚本
3. 保存场景为 `res://scenes/ui/network_menu.tscn`
4. 添加必要的UI节点（VBoxContainer, Labels, Buttons等）

### 5. 添加游戏设置对话框

1. 创建新的Control场景
2. 添加 `NetworkGameSetupDialog` 脚本
3. 保存场景为 `res://scenes/ui/network_game_setup_dialog.tscn`
4. 添加必要的UI节点

### 6. 修改主游戏管理器

在 `scripts/manager/main_game_manager.gd` 中添加网络功能：

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
	# ... 其他初始化代码
```

### 7. 添加开始菜单按钮

在 `scripts/ui/start_menu/start_menu_root.gd` 中添加：

```gdscript
## 联机模式
func _on_network_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/network_menu.tscn")
```

## 场景配置

### NetworkManager场景结构

```
NetworkManager
├── (脚本: NetworkManager)
```

### NetworkMenu场景结构

```
NetworkMenu
├── VBoxContainer
│   ├── TitleLabel
│   ├── ConnectionStatusLabel
│   ├── IPContainer
│   │   ├── HostIPLabel
│   │   ├── HostIPInput
│   │   ├── PortLabel
│   │   └── PortInput
│   ├── ButtonsContainer
│   │   ├── HostButton
│   │   └── ClientButton
│   ├── PlayerCountLabel
│   ├── GameInfoContainer
│   │   ├── GameModeLabel
│   │   ├── MapLabel
│   │   └── FactionLabel
│   ├── PlayerList
│   ├── ReadyButton
│   ├── StartButton
│   └── BackButton
```

### NetworkGameSetupDialog场景结构

```
NetworkGameSetupDialog
├── DialogContainer
│   ├── Panel
│   │   ├── TitleLabel
│   │   ├── GameModeLabel
│   │   ├── MapSelectionContainer
│   │   ├── FactionSelectionContainer
│   │   └── ButtonsContainer
│   │       ├── ConfirmButton
│   │       └── CancelButton
```

## 资源配置

### 音频资源

确保以下音频资源存在：

- `res://assets/audio/BGM/start_menu.mp3` - 开始菜单BGM
- `res://assets/audio/SFX/ui_open.mp3` - UI打开音效
- `res://assets/audio/SFX/ui_close.mp3` - UI关闭音效
- `res://assets/audio/SFX/ui_click.mp3` - UI点击音效
- `res://assets/audio/SFX/ui_confirm.mp3` - UI确认音效
- `res://assets/audio/SFX/ui_cancel.mp3` - UI取消音效

### 主题配置

确保存在PVZ主题：

- `res://data/PVZ_theme.tres` - PVZ主题文件

## 测试配置

### 本地测试

1. 在Godot编辑器中运行项目
2. 点击"联机模式"按钮
3. 点击"创建主机"
4. 查看控制台输出确认主机创建成功

### 多实例测试

1. 运行第一个实例（主机）
2. 运行第二个实例（客户端）
3. 在客户端中输入主机IP和端口
4. 点击"加入游戏"
5. 验证玩家连接成功

## 常见配置问题

### 1. NetworkManager未找到

**症状**: 控制台显示"NetworkManager未找到"

**解决方案**:
- 确保NetworkManager已添加到自动加载列表
- 检查场景名称是否正确
- 确保脚本路径正确

### 2. 无法连接到主机

**症状**: 客户端无法连接到主机

**解决方案**:
- 检查主机IP是否正确
- 检查端口是否正确
- 检查防火墙设置
- 确保主机已启动并运行

### 3. UI不显示

**症状**: 网络菜单或游戏设置对话框不显示

**解决方案**:
- 检查场景是否正确加载
- 检查UI节点是否正确配置
- 查看控制台是否有错误信息
- 确保主题文件存在

## 性能配置

### 网络优化

```gdscript
# 在NetworkManager中设置
@export var max_players: int = 4  # 限制最大玩家数
@export var enable_history: bool = false  # 禁用事件历史记录
@export var debug_mode: bool = false  # 禁用调试模式
```

### 游戏性能优化

```gdscript
# 在主游戏管理器中设置
@export var is_network_game: bool = true
@export var sync_frequency: float = 1.0  # 同步频率（秒）
```

## 安全配置

### 网络安全

```gdscript
# 在NetworkManager中添加
@export var enable_auth: bool = false  # 启用身份验证
@export var enable_encryption: bool = false  # 启用加密
```

### 玩家限制

```gdscript
# 在NetworkManager中添加
@export var max_players: int = 4  # 最大玩家数
@export var kick_inactive_players: bool = true  # 踢出不活跃玩家
@export var kick_inactive_time: float = 300.0  # 不活跃时间（秒）
```

## 高级配置

### 自定义端口范围

```gdscript
# 在NetworkManager中添加
@export var min_port: int = 10000
@export var max_port: int = 20000
```

### 自定义游戏模式

```gdscript
# 在NetworkGameSetupDialog中添加
var custom_game_modes: Dictionary = {
	"custom_mode_1": "自定义模式1",
	"custom_mode_2": "自定义模式2"
}
```

## 配置文件示例

### network_manager_config.gd

```gdscript
extends Resource
class_name NetworkManagerConfig

## 网络管理器配置

## 网络设置
var network_port: int = 25565
var max_players: int = 4
var enable_encryption: bool = false

## 游戏设置
var default_game_mode: String = "adventure"
var default_map: String = "day"
var default_faction: String = "plants"

## 性能设置
var sync_frequency: float = 1.0
var enable_history: bool = false
var debug_mode: bool = false

## 安全设置
var enable_auth: bool = false
var enable_kick_inactive: bool = true
var kick_inactive_time: float = 300.0

## 创建默认配置
static func create_default_config() -> NetworkManagerConfig:
	var config = NetworkManagerConfig.new()
	return config
```

## 验证配置

### 配置验证脚本

```gdscript
func validate_network_config() -> bool:
	var errors: Array[String] = []

	# 检查NetworkManager
	if not has_node("/root/NetworkManager"):
		errors.append("NetworkManager未找到")

	# 检查配置
	if network_manager == null:
		errors.append("NetworkManager为null")

	# 检查端口
	var port = network_manager.get_host_port()
	if port == 0:
		errors.append("主机端口未设置")

	# 检查玩家数
	var max_players = network_manager.get_max_players()
	if max_players == 0:
		errors.append("最大玩家数未设置")

	# 输出错误
	if errors.size() > 0:
		for error in errors:
			print("配置错误: %s" % error)
		return false

	return true
```

## 更新配置

### 版本1.0

- 基本主机-客户端架构
- 支持最多4名玩家
- 游戏模式、地图、阵营选择

### 版本1.1

- 添加语音聊天
- 添加屏幕共享
- 优化网络延迟

### 版本1.2

- 添加更多游戏模式
- 添加更多地图
- 添加更多阵营
- 优化性能

## 参考资料

- Godot官方文档: https://docs.godotengine.org/zh-cn/4.x/tutorials/networking/high_level_multiplayer.html
- ENetMultiplayerPeer: https://docs.godotengine.org/zh-cn/4.x/classes/class_enetmultiplayerpeer.html
- RPC系统: https://docs.godotengine.org/zh-cn/4.x/tutorials/networking/high_level_multiplayer.html#remote-procedure-calls
