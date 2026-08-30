# 碰撞层系统文档

## 层位分配总表

| 位 | 值 | 名称 | 用途 | 代码位置 |
|---|---|---|---|---|
| 0 | 1 | (保留) | 未使用 | — |
| 1 | 2 | 植物(检测层) | 植物的 HurtBoxDetection | `plant_000_base.tscn:267` |
| 2 | 4 | 僵尸(检测层) | 僵尸的 HurtBoxDetection | `zombie_000_base.tscn:299` |
| 3 | 8 | 子弹(基础层) | 子弹 Area2DAttack 的 layer | `bullet_000_norm_base.tscn:33` |
| 4 | 16 | 僵尸攻击中(检测层) | HurtBoxDetectionOnAttack，大嘴花/窝瓜可检测 | `zombie_000_base.tscn:316` |
| 5 | 32 | 魅惑僵尸(检测层) | 被魅惑后切换到此层 | 运行时设置：`component_hurt_box_zombie.gd:22` |
| 6 | 64 | (保留) | 未使用 | — |
| 7 | 128 | 篮球子弹层 | 篮球子弹专用 | `bullet_013_basketball.tscn:20` |
| 8 | 256 | 植物(受击层) | 植物的 HurtBoxReal | `plant_000_base.tscn:276` |
| 9 | 512 | 僵尸(受击层) | 僵尸的 HurtBoxReal | `zombie_000_base.tscn:308` |
| 10 | 1024 | 魅惑僵尸(受击层) | 被魅惑后切换到此层 | 运行时设置：`component_hurt_box_zombie.gd:23` |
| 11 | 2048 | 道具(检测层) | 脑子、罐子、梯子的检测层 | `brain_on_zombie_mode.tscn:22`, `scary_pot.tscn:133`, `ladder.tscn:20` |
| 12 | 4096 | 道具(受击层) | 脑子、罐子、梯子的受击层 | `brain_on_zombie_mode.tscn:30`, `scary_pot.tscn:142`, `ladder.tscn:28` |

---

## 两层体系

项目为每种实体使用**两个 Area2D**：

```
HurtBoxDetection (检测层) — 被别人的 DetectComponent Area2D 探测
HurtBoxReal      (受击层) — 被子弹的 Area2DAttack 探测
```

### 为什么分两层？

- **检测层**：用于 DetectComponent 的射线检测（判断是否开始攻击），碰撞形状更大/更前
- **受击层**：用于子弹实际命中判定，碰撞形状贴合身体

---

## 植物碰撞配置

**定义位置**: `scenes/character/plant/plant_000_base.tscn`

```
HurtBoxDetection.collision_layer = 2   (层1)
HurtBoxDetection.collision_mask  = 0
HurtBoxReal.collision_layer      = 256 (层8)
```

植物没有额外的 HurtBoxDetectionOnAttack。

---

## 僵尸碰撞配置

**定义位置**: `scenes/character/zombie/zombie_000_base.tscn`

```
HurtBoxDetection.collision_layer       = 4   (层2)
HurtBoxDetection.collision_mask        = 0
HurtBoxReal.collision_layer            = 512 (层9)
HurtBoxDetectionOnAttack.collision_layer = 16  (层4)
HurtBoxDetectionOnAttack.collision_mask  = 0
```

### 魅惑后切换

**代码位置**: `scripts/character/components/component_hurt_box_zombie.gd:21-23`

```gdscript
func owner_be_hypno():
    hurt_box_detection.collision_layer = 32    # 层5 → 植物阵营检测层
    hurt_box_real.collision_layer = 1024       # 层10 → 植物阵营受击层
```

切换后：
| 节点 | 魅惑前 | 魅惑后 |
|---|---|---|
| HurtBoxDetection | 4 (层2) | 32 (层5) |
| HurtBoxReal | 512 (层9) | 1024 (层10) |

---

## 子弹碰撞配置

### 基础子弹

**定义位置**: `scenes/bullet/bullet_000_norm_base.tscn:33-34`

```
Area2DAttack.collision_layer = 8   (层3)
Area2DAttack.collision_mask  = 512 (层9) → 只检测僵尸HurtBoxReal
```

### 直线子弹(豌豆等)

**定义位置**: `scenes/bullet/bullet_000_linear_base.tscn:11`

```
Area2DAttack.collision_mask = 513 (层0+层9) → 检测层1+层10
```

513 = 1 + 512，即层1和层10。

### 各子弹类型 mask 一览

| 子弹场景 | mask值 | 检测的层 | 代码位置 |
|---|---|---|---|
| `bullet_000_norm_base` | 512 | 层9(僵尸受击) | `bullet_000_norm_base.tscn:34` |
| `bullet_000_linear_base` | 513 | 层1+层10 | `bullet_000_linear_base.tscn:11` |
| `bullet_006_pea_fire` | 512 | 层9(僵尸受击) | `bullet_006_pea_fire.tscn:1050` |
| `bullet_012_melon` | 512 | 层9(僵尸受击) | `bullet_012_melon.tscn:76` |
| `bullet_013_basketball` | 256 | 层8(植物受击) | `bullet_013_basketball.tscn:21` |
| `bullet_015_winter_melon` | 512 | 层9(僵尸受击) | `bullet_015_winter_melon.tscn:74` |
| `bullet_016_cob_cannon` | 2068 | 多层 | `bullet_016_cob_cannon.tscn:58` |
| `bullet_1001_bowling` | — | 无mask(只layer) | `bullet_1001_bowling.tscn:65` |
| `bullet_1002_bowling_bomb/A2DBomb` | 4116 | 多层 | `bullet_1002_bowling_bomb.tscn:261` |

---

## 子弹碰撞回调

**代码位置**: `scripts/bullet/bullet_000_norm_base.gd:104-132`

```gdscript
func _on_area_2d_attack_area_entered(area: Area2D) -> void:
    var enemy:Character000Base = area.owner
    if enemy is Plant000Base:
        if bullet_camp == CharacterRegistry.CharacterType.Plant:
            return  # 植物阵营子弹不打植物
        if not enemy.curr_be_attack_status & can_attack_plant_status:
            return  # 状态不符
    elif enemy is Zombie000Base:
        if bullet_camp == CharacterRegistry.CharacterType.Zombie:
            return  # 僵尸阵营子弹不打僵尸
        if not enemy.curr_be_attack_status & can_attack_zombie_status:
            return  # 状态不符
    # ... 行属性检查 ...
    attack_once(enemy)
```

**关键**: 信号触发的前提是子弹 mask 与目标 layer 有交集。如果 mask 不包含目标层，`area_entered` 信号根本不会触发。

---

## DetectComponent 层常量

**代码位置**: `scripts/character/components/detect_component/component_detect.gd:24-36`

```gdscript
# 检测层(Detection) — 被 DetectComponent 的 Area2D mask 探测
C_LayTypeValueDetection = {
    PlantEnemy:  4,       # 层2: 僵尸HurtBoxDetection
    ZombieEnemy: 2 + 32,  # 层1+层5: 植物HurtBoxDetection + 魅惑僵尸HurtBoxDetection
    Item:        2048,    # 层11: 道具检测层
}
C_AttackZombieDetection = 16  # 层4: 僵尸攻击中HurtBoxDetectionOnAttack

# 受击层(Real) — 被子弹的 Area2DAttack mask 探测
C_LayTypeValueReal = {
    PlantEnemy:  512,         # 层9: 僵尸HurtBoxReal
    ZombieEnemy: 256 + 1024,  # 层8+层10: 植物HurtBoxReal + 魅惑僵尸HurtBoxReal
    Item:        4096,        # 层12: 道具受击层
}
```

### DetectComponent 初始化

```gdscript
func _ready() -> void:
    if owner is Plant000Base:
        update_curr_collision_lay(1)  # 植物：检测 PlantEnemy(mask=4)
    elif owner is Zombie000Base:
        update_curr_collision_lay(2)  # 僵尸：检测 ZombieEnemy(mask=2+32=34)
```

### update_curr_collision_lay 逻辑

```gdscript
func update_curr_collision_lay(curr_character:int):
    if is_dectection:
        _set_curr_collision_lay_value(curr_character, C_LayTypeValueDetection)
    else:
        _set_curr_collision_lay_value(curr_character, C_LayTypeValueReal)
    for node in get_children():
        if node is Area2D:
            node.collision_mask = curr_collision_lay  # 设置每个检测区域的mask
```

---

## DetectComponent 场景中的 mask 值

植物的 DetectComponent Area2D mask 由 `_ready()` 动态设置为 4（检测僵尸HurtBoxDetection）。

僵尸的 DetectComponent Area2D mask 由 `_ready()` 动态设置为 34（检测植物HurtBoxDetection + 魅惑僵尸HurtBoxDetection）。

场景文件中的初始值（会被代码覆盖）：
| 场景 | 节点 | mask | 代码位置 |
|---|---|---|---|
| `zombie_000_base.tscn` | DetectComponent/Area2d | 34 | `zombie_000_base.tscn:262` |
| `plant_001_pea_shooter_single.tscn` | DetectComponent/Area2D | 4 | `plant_001_pea_shooter_single.tscn:1219` |

---

## 道具碰撞配置

| 道具场景 | 检测层 | 受击层 | 代码位置 |
|---|---|---|---|
| `brain_on_zombie_mode.tscn` | 2048 (层11) | 4096 (层12) | `:22-23, :30-31` |
| `scary_pot.tscn` | 2048 (层11) | 4096 (层12) | `:133-134, :142-143` |
| `ladder.tscn` | 2048 (层11) | 4096 (层12) | `:20-21, :28-29` |

梯子额外有 `collision_mask = 4`（层2，检测僵尸HurtBoxDetection）。

---

## 割草机/泳池清洁器

| 场景 | mask | 检测的层 | 代码位置 |
|---|---|---|---|
| `lawn_mower.tscn` | 513 | 层1+层10 | `:146` |
| `pool_cleaner.tscn` | 513 | 层1+层10 | `:217` |
| `roof_cleaner.tscn` | 512 | 层9 | `:96` |

---

## 坡道碰撞

**定义位置**: `scenes/main_game_bg/slope.tscn`

```
Area2DSlopeDetection.collision_mask = 1537
```

1537 = 1 + 512 + 1024 = 层1 + 层9 + 层10，检测保留层、僵尸受击层、魅惑僵尸受击层。

---

## 豌豆僵尸碰撞修复

**问题**: 豌豆子弹默认 mask=513（层1+层10），不包含植物受击层（层8=256）和魅惑僵尸受击层（层10=1024）。

**修复位置**: `scripts/character/zombie/zombie_031_pea_zombie.gd:82-86`

```gdscript
Global.main_game.bullets.add_child(bullet)
# area_2d_attack 是 @onready，必须在 add_child 之后设置
bullet.area_2d_attack.collision_mask = 256 + 512 + 1024  # 层8+层9+层10
```

修复后 mask=1792 包含：
- 256 (层8): 植物HurtBoxReal
- 512 (层9): 僵尸HurtBoxReal
- 1024 (层10): 魅惑僵尸HurtBoxReal

阵营过滤在 `bullet_000_norm_base.gd:104-132` 的回调中处理。

---

## 信号触发条件

Godot 的 `area_entered` 信号触发条件：

```
A.collision_mask & B.collision_layer != 0
```

即 A 的 mask 和 B 的 layer 有交集时，A 的 `area_entered` 会收到 B。

**子弹命中目标的前提**：
1. 子弹 `Area2DAttack.collision_mask` 包含目标的 `HurtBoxReal.collision_layer`
2. 目标 `HurtBoxReal.monitorable = true`（由 `HurtBoxComponent.enable_component()` 控制）
3. 子弹 `Area2DAttack.monitoring = true`（默认值）

三者缺一不可。

---

## 新增子弹/角色时的注意事项

1. **新子弹类型**: 确保 `collision_mask` 包含目标阵营的 `HurtBoxReal` 层
2. **新僵尸类型**: 确保 `HurtBoxReal.collision_layer = 512`，`HurtBoxDetection.collision_layer = 4`
3. **新植物类型**: 确保 `HurtBoxReal.collision_layer = 256`，`HurtBoxDetection.collision_layer = 2`
4. **魅惑相关**: 魅惑后层会切换（512→1024，4→32），子弹 mask 必须包含两个阵营的层
5. **阵营过滤**: 不要只靠 mask 过滤，子弹回调中的 `bullet_camp` 检查是第二道防线
