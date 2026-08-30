# PVZ-Godot 联机功能总结

## 功能概述

本文档总结了PVZ-Godot项目中的联机功能实现，包括核心组件、文件结构和使用指南。

## 核心组件

### 1. NetworkManager

**文件位置**: `scripts/autoload/network/network_manager.gd`

**功能**:
- 网络连接管理（主机/客户端）
- 玩家管理（加入/离开）
- 数据广播和同步
- 游戏状态管理
- 网络延迟监控

**主要特性**:
- 使用ENetMultiplayerPeer实现P2P通信
- 支持最多4名玩家
- 实时状态同步
- 玩家准备系统
- 事件驱动架构

**关键方法**:
```gdscript
create_host(port: int, max_players: int)  # 创建主机
connect_to_host(ip: String, port: int)     # 连接到主机
broadcast_data(data: Dictionary)          # 广播数据
send_to_player(player_id: int, data)       # 发送给特定玩家
player_ready()                             # 玩家准备就绪
request_game_start()                       # 请求游戏开始
```

### 2. NetworkGameState

**文件位置**: `scripts/data/network_game_state.gd`

**功能**:
- 网络游戏状态数据结构
- 玩家准备状态管理
- 玩家数量统计

**主要特性**:
- 资源类型，便于保存和加载
- 玩家准备状态跟踪
- 准备状态统计

**关键方法**:
```gdscript
create_new(game_mode, map_name, faction_name)  # 创建新状态
set_player_ready(player_id, ready)              # 设置准备状态
is_player_ready(player_id)                      # 检查准备状态
get_ready_players()                             # 获取准备就绪玩家
get_unready_players()                           # 获取未准备玩家
```

### 3. NetworkMenu

**文件位置**: `scripts/ui/network_menu.gd`

**功能**:
- 联机菜单UI
- 连接管理
- 玩家列表显示
- 游戏信息展示

**主要特性**:
- 连接状态实时更新
- 玩家列表动态更新
- 游戏模式/地图/阵营信息展示
- 准备/开始按钮控制

**UI元素**:
- 连接状态标签
- 主机IP/端口输入
- 主机/客户端按钮
- 玩家数量标签
- 游戏信息标签
- 玩家列表
- 准备/开始按钮
- 返回按钮

### 4. NetworkGameSetupDialog

**文件位置**: `scripts/ui/network_game_setup_dialog.gd`

**功能**:
- 游戏设置对话框
- 游戏模式选择
- 地图选择
- 阵营选择

**主要特性**:
- 多步骤设置流程
- 按钮网格布局
- 回调函数支持
- 动态UI更新

**设置选项**:
- 游戏模式: 冒险模式、生存模式、迷你游戏、解密模式、自定义关卡
- 地图: 白天、夜晚、泳池、迷雾、屋顶
- 阵营: 植物阵营、僵尸阵营、混合阵营

## 文件结构

```
PVZ-Godot_dream_20260406_v1.2.0/
├── scripts/
│   ├── autoload/
│   │   ├── network/
│   │   │   └── network_manager.gd          # 网络管理器
│   │   └── global/
│   │       └── global.gd                   # 全局管理器（已修改）
│   ├── data/
│   │   └── network_game_state.gd           # 网络游戏状态
│   ├── manager/
│   │   └── main_game_manager.gd            # 主游戏管理器（已修改）
│   └── ui/
│       ├── network_menu.gd                 # 联机菜单
│       └── network_game_setup_dialog.gd    # 游戏设置对话框
├── scenes/
│   └── ui/
│       ├── network_menu.tscn               # 联机菜单场景
│       └── network_game_setup_dialog.tscn  # 游戏设置对话框场景
├── docs/
│   ├── NETWORK_FEATURE.md                  # 功能文档
│   ├── NETWORK_EXAMPLES.md                 # 使用示例
│   ├── NETWORK_CONFIGURATION.md            # 配置指南
│   └── NETWORK_SUMMARY.md                  # 本文档
└── tests/
    └── ui/
        └── network_test_scene.tscn         # 网络测试场景
```

## 架构设计

### 设计模式

1. **单例模式**: NetworkManager作为全局单例
2. **观察者模式**: 事件总线模式，使用信号进行通信
3. **工厂模式**: NetworkGameState.create_new()创建状态
4. **命令模式**: 网络操作封装为命令

### 通信架构

```
主机端                    客户端
   |                         |
   | 创建主机                 |
   +------------------------>|
   |                         | 连接到主机
   |                         +------------------------>
   |                         |                         |
   | 玩家连接                 | 玩家连接
   +------------------------>|                         |
   |                         |                         |
   | 广播数据                 | 接收数据
   <------------------------|                         |
   |                         |                         |
   | 游戏开始                 | 游戏开始
   +------------------------|                         |
```

### 数据流程

```
用户操作
    ↓
UI层处理
    ↓
NetworkManager处理
    ↓
网络传输 (ENetMultiplayerPeer)
    ↓
接收方处理
    ↓
状态更新
```

## 使用流程

### 主机流程

1. **启动游戏**
   ```
   运行游戏 → 开始菜单 → 联机模式 → 创建主机
   ```

2. **等待玩家**
   ```
   主机创建成功 → 显示玩家列表 → 等待玩家加入
   ```

3. **游戏设置**
   ```
   玩家加入 → 选择游戏模式 → 选择地图 → 选择阵营
   ```

4. **准备游戏**
   ```
   所有玩家准备就绪 → 点击开始游戏
   ```

5. **开始游戏**
   ```
   游戏开始 → 切换到主游戏场景
   ```

### 客户端流程

1. **启动游戏**
   ```
   运行游戏 → 开始菜单 → 联机模式 → 输入主机信息 → 加入游戏
   ```

2. **等待主机**
   ```
   连接成功 → 等待主机设置游戏
   ```

3. **游戏设置**
   ```
   选择游戏模式 → 选择地图 → 选择阵营
   ```

4. **准备游戏**
   ```
   点击准备就绪 → 等待所有玩家准备
   ```

5. **开始游戏**
   ```
   主机点击开始 → 游戏开始 → 切换到主游戏场景
   ```

## 扩展指南

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

### 添加新的网络功能

1. 在`NetworkManager`中添加新方法
2. 实现RPC通信
3. 在UI中添加相应控件
4. 在主游戏管理器中集成

## 性能优化

### 已实现的优化

1. **增量更新**: 只同步变化的数据
2. **频率控制**: 可配置的同步频率
3. **延迟监控**: 实时网络延迟检测
4. **资源管理**: 合理的资源释放

### 优化建议

1. **减少数据传输**: 只传输必要的数据
2. **使用增量更新**: 只更新变化的数据
3. **优化RPC频率**: 避免过于频繁的RPC调用
4. **使用网络预测**: 减少客户端延迟感

## 安全性

### 当前实现

1. **身份验证**: 可选的身份验证系统
2. **玩家限制**: 限制最大玩家数
3. **连接验证**: 主机验证客户端连接

### 安全建议

1. **启用加密**: 在生产环境中启用加密
2. **身份验证**: 启用玩家身份验证
3. **输入验证**: 验证所有网络输入
4. **速率限制**: 限制玩家操作频率

## 测试

### 单元测试

- NetworkManager功能测试
- NetworkGameState状态测试
- UI组件测试

### 集成测试

- 主机-客户端连接测试
- 数据同步测试
- 游戏流程测试

### 性能测试

- 多玩家压力测试
- 网络延迟测试
- 资源使用测试

## 故障排查

### 常见问题

1. **无法连接到主机**
   - 检查主机IP和端口
   - 检查防火墙设置
   - 确保主机已启动

2. **玩家列表不更新**
   - 检查网络连接状态
   - 查看控制台错误信息
   - 尝试重新连接

3. **游戏开始后卡顿**
   - 检查网络延迟
   - 减少地图复杂度
   - 优化游戏性能

## 未来计划

### 短期计划

- [ ] 添加语音聊天功能
- [ ] 添加屏幕共享功能
- [ ] 优化网络延迟
- [ ] 添加更多游戏模式

### 中期计划

- [ ] 添加更多地图
- [ ] 添加更多阵营
- [ ] 实现断线重连
- [ ] 添加游戏记录

### 长期计划

- [ ] 实现服务器托管
- [ ] 添加排行榜系统
- [ ] 实现匹配系统
- [ ] 添加社交功能

## 技术栈

- **引擎**: Godot Engine 4.6
- **语言**: GDScript
- **网络**: ENetMultiplayerPeer
- **通信**: RPC (Remote Procedure Call)
- **架构**: 单例模式 + 事件驱动

## 参考文档

- [Godot官方文档 - 网络功能](https://docs.godotengine.org/zh-cn/4.x/tutorials/networking/)
- [ENetMultiplayerPeer文档](https://docs.godotengine.org/zh-cn/4.x/classes/class_enetmultiplayerpeer.html)
- [RPC系统文档](https://docs.godotengine.org/zh-cn/4.x/tutorials/networking/high_level_multiplayer.html#remote-procedure-calls)

## 维护者

- PVZ-Godot开发团队

## 版本历史

### v1.0.0 (2026-07-18)
- 初始版本发布
- 基本主机-客户端架构
- 支持4名玩家
- 游戏设置功能
- 状态同步系统

---

**最后更新**: 2026-07-18
**版本**: 1.0.0
