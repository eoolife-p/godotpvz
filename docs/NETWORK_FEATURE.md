# PVZ-Godot 联机功能文档

## 概述

本文档描述了PVZ-Godot项目中的联机功能实现。

## 功能特性

- **主机-客户端架构**: 支持创建主机和加入主机
- **多人游戏**: 最多支持4名玩家
- **游戏设置**: 支持选择游戏模式、地图和阵营
- **玩家管理**: 玩家加入/离开通知
- **状态同步**: 游戏状态实时同步

## 架构设计

### 核心组件

1. **NetworkManager** (`scripts/autoload/network/network_manager.gd`)
   - 网络连接管理
   - 玩家管理
   - 数据广播
   - 游戏状态同步

2. **NetworkGameState** (`scripts/data/network_game_state.gd`)
   - 网络游戏状态数据结构
   - 玩家准备状态管理

3. **NetworkMenu** (`scripts/ui/network_menu.gd`)
   - 联机菜单UI
   - 连接管理
   - 玩家列表显示

4. **NetworkGameSetupDialog** (`scripts/ui/network_game_setup_dialog.gd`)
   - 游戏设置对话框
   - 游戏模式/地图/阵营选择

### 通信协议

网络使用Godot的ENetMultiplayerPeer进行P2P通信：

- **主机**: 创建服务器，监听端口
- **客户端**: 连接到主机
- **数据传输**: 使用RPC进行数据同步

## 使用方法

### 1. 创建主机

1. 运行游戏
2. 在开始菜单点击"联机模式"按钮
3. 点击"创建主机"
4. 选择游戏模式、地图和阵营
5. 点击"准备"
6. 等待其他玩家加入

### 2. 加入游戏

1. 运行游戏
2. 在开始菜单点击"联机模式"按钮
3. 输入主机IP和端口
4. 点击"加入游戏"
5. 选择游戏模式、地图和阵营
6. 点击"准备"
7. 等待所有玩家准备就绪后点击"开始游戏"

### 3. 开始游戏

- 只有主机可以点击"开始游戏"
- 需要所有玩家都点击"准备"
- 点击后游戏开始并切换到主游戏场景

## 配置说明

### 端口配置

默认端口: 25565

可以通过修改`network_menu.gd`中的`port_input.text`来修改端口。

### 最大玩家数

默认最大玩家数: 4

可以在`NetworkManager.create_host()`中修改。

## 数据流程

### 主机流程

1. 创建主机
2. 等待玩家连接
3. 玩家选择游戏设置
4. 玩家准备就绪
5. 所有玩家就绪后开始游戏

### 客户端流程

1. 连接到主机
2. 等待主机确认连接
3. 选择游戏设置
4. 玩家准备就绪
5. 等待所有玩家就绪后开始游戏

## 扩展功能

### 添加新的游戏模式

1. 在`NetworkGameSetupDialog`中添加新模式选项
2. 在`game_modes`字典中添加新模式
3. 在`main_game_manager.gd`中处理新模式逻辑

### 添加新的地图

1. 在`NetworkGameSetupDialog`中添加新地图选项
2. 在`map_options`字典中添加新地图
3. 在`const_level_data.gd`中添加地图配置

### 添加新的阵营

1. 在`NetworkGameSetupDialog`中添加新阵营选项
2. 在`faction_options`字典中添加新阵营
3. 在游戏逻辑中使用阵营信息

## 调试

### 查看网络状态

在控制台中查看NetworkManager的调试信息：

```gdscript
NetworkManager.print_debug_info()
```

### 查看网络延迟

```gdscript
NetworkManager.get_network_latency()
NetworkManager.get_network_average_latency()
```

### 查看玩家列表

```gdscript
NetworkManager.get_all_players()
```

## 常见问题

### 1. 无法连接到主机

- 检查主机IP是否正确
- 检查端口是否正确
- 检查防火墙设置
- 确保主机已启动

### 2. 游戏开始后卡顿

- 检查网络延迟
- 减少地图复杂度
- 优化游戏性能

### 3. 玩家列表不更新

- 检查网络连接状态
- 查看控制台错误信息
- 尝试重新连接

## 性能优化建议

1. **减少数据传输**: 只传输必要的数据
2. **使用增量更新**: 只更新变化的数据
3. **优化RPC频率**: 避免过于频繁的RPC调用
4. **使用网络预测**: 减少客户端延迟感

## 未来计划

- [ ] 语音聊天功能
- [ ] 屏幕共享
- [ ] 更多游戏模式
- [ ] 更多的地图和阵营
- [ ] 游戏记录和统计
- [ ] 排队系统

## 技术栈

- Godot Engine 4.6
- ENetMultiplayerPeer
- GDScript
- RPC (Remote Procedure Call)

## 许可证

与主项目许可证相同。
