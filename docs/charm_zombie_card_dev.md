# PVZ-Godot 魅惑僵尸卡 开发文档

## 功能概述

在选卡界面新增第4页——**魅惑僵尸页**。该页复制所有已解锁的僵尸卡片，每张卡片带有原版魅惑菇的视觉效果（粉紫色调 + 左右反转），放置到草坪后调用游戏原版 `be_hypno()` 系统，僵尸会反转方向、变色、为玩家作战。

---

## 整体架构

```
选卡界面 (CardSlotCandidate)
  ├── 第1页: 植物卡
  ├── 第2页: 植物卡
  ├── 第3页: 普通僵尸卡
  └── 第4页: 魅惑僵尸卡  ← 新增
        │
        ├── 复制所有curr_zombie中的僵尸卡片
        ├── 设置 is_charm_card = true
        ├── character_static.modulate = Color(1, 0.5, 1)  粉紫色调
        └── character_static.scale.x 反转  左右镜像
```

放置到草坪时：
```
玩家放置卡片 → HM_Character.click_cell()
  └── 检查 curr_card.is_charm_card == true
        └── zombie.be_hypno()  调用游戏原版魅惑系统
              ├── body.set_other_color(HypnoColor, Color(1,0.5,1))
              ├── update_direction_x_root(-1)  反转方向
              └── 信号触发：攻击目标变为其他僵尸、移动方向反转
```

---

## 涉及文件及改动

### 1. `scripts/ui/card/card_base.gd` — 新增属性

```gdscript
## 是否为魅惑卡片（放置僵尸时带魅惑滤镜）
var is_charm_card := false
```

所有卡片（Card）继承自 CardBase，魅惑卡片通过此属性标记身份。

### 2. `scripts/ui/card/card.gd` — 悬停名称显示

在 `_on_button_mouse_entered()` 末尾新增判断：

```gdscript
if is_charm_card:
    $PlantName.text = "魅惑 " + $PlantName.text
    $PlantName.scale = Vector2(0.45, 0.45)
```

效果：鼠标悬停魅惑卡片时，名称显示为 "魅惑 僵尸名"（如 "魅惑 普通僵尸"）。

### 3. `scripts/ui/card/card_slot/card_slot_norm/card_slot_candidate.gd` — 魅惑页生成

核心函数 `_init_card_slot_candidate_zombie()` 末尾新增魅惑页生成逻辑：

```gdscript
## 魅惑僵尸独立最后一页：复制所有僵尸卡片 + 魅惑样式
var charm_grid = grid_container_zombie.duplicate()
all_card_page.add_child(charm_grid)
all_card_page_array.append(charm_grid)
charm_grid.visible = false
var charm_placeholders = charm_grid.get_children()
var charm_slot_index := 0

for zombie_type in Global.global_game_state.curr_zombie:
    if not AllCards.all_zombie_card_prefabs.has(zombie_type):
        continue
    var orig_card: Card = AllCards.all_zombie_card_prefabs[zombie_type]

    # 先在原卡片上设置魅惑样式，再复制
    # （duplicate()的节点@onready变量为nil，必须在原卡上设置）
    var orig_modulate = orig_card.character_static.modulate
    var orig_scale = orig_card.character_static.scale
    orig_card.character_static.modulate = Color(1, 0.5, 1)  # 粉紫色调
    orig_card.character_static.scale.x = -orig_scale.x       # 左右反转
    var charm_card := orig_card.duplicate() as Card
    orig_card.character_static.modulate = orig_modulate      # 恢复原卡
    orig_card.character_static.scale = orig_scale

    charm_card.is_charm_card = true

    var charm_container = SceneRegistry.CARD_CANDIDATE_CONTAINER.instantiate()
    charm_container.init_card_in_seed_chooser(charm_card)
    charm_placeholders[charm_slot_index].add_child(charm_container)
    all_card_candidate_containers_zombie[orig_card.card_id + 10000] = charm_container
    charm_container.visible = false
    charm_slot_index += 1

# 魅惑页始终可见（不随normal_pages翻页隐藏）
for zombie_type in Global.global_game_state.curr_zombie:
    var charm_key = AllCards.zombie_card_ids[zombie_type] + 10000
    if charm_key in all_card_candidate_containers_zombie:
        all_card_candidate_containers_zombie[charm_key].visible = true

grid_container_zombie.queue_free()
```

**关键设计：**

| 要点 | 说明 |
|------|------|
| key = card_id + 10000 | 避免与普通僵尸卡 key 冲突，字典存储魅惑卡 |
| apply-then-duplicate | `character_static` 是 `@onready` 变量，duplicate 出来的节点为 nil，必须在原卡上设置后再复制 |
| modulate 而非 shader | 复用游戏原版 `body_character.gd` 的 `HypnoColor` 机制，不引入自定义 shader |
| 魅惑页始终 visible | 不参与普通页面的翻页逻辑，始终显示 |

### 4. `scripts/manager/hand_manager/hm_character.gd` — 放置时应用魅惑

**行模式** (`click_cell()` 约第193行)：

```gdscript
var zombie:Zombie000Base = Global.main_game.zombie_manager.create_norm_zombie(...)

# 魅惑僵尸卡片放置时调用原版魅惑效果
if curr_card.is_charm_card:
    zombie.be_hypno()
```

**列模式** (`_click_cell_column()` 约第278行)：

```gdscript
var zombie:Zombie000Base = Global.main_game.zombie_manager.create_norm_zombie(...)

if curr_card.is_charm_card:
    zombie.be_hypno()
```

`be_hypno()` 是游戏原版函数（`character_000_base.gd`），调用后触发：

```gdscript
func be_hypno():
    is_hypno = true
    signal_character_be_hypno.emit()     # 信号触发以下连锁反应
    update_direction_x_root(-1)          # 反转方向
```

信号连接（`zombie_000_base.gd`）：
- `body.owner_be_hypno()` → `set_other_color(HypnoColor, Color(1,0.5,1))` → 粉紫色
- `hurt_box_component.owner_be_hypno()` → 伤害判定改为友方
- `attack_component.owner_be_hypno()` → 攻击目标变为敌方僵尸
- `move_component._walking_start()` → 重新开始移动（方向反转）

### 5. 选卡保存/重选 (`card_slot_norm.gd`)

**保存时** (`_on_texture_button_pressed()`)：

```gdscript
elif card.card_zombie_type != CharacterRegistry.ZombieType.Null:
    card_type_data["zombie_type"] = card.card_zombie_type
    if card.is_charm_card:
        card_type_data["is_charm_card"] = true  # 新增
```

**重选时** (`_on_re_card_button_pressed()`)：

```gdscript
elif card_type_data.has("zombie_type"):
    var zombie_type = card_type_data["zombie_type"]
    var is_charm:bool = card_type_data.get("is_charm_card", false)  # 新增
    var card_key = AllCards.zombie_card_ids[zombie_type]
    if is_charm:
        card_key += 10000  # 魅惑卡用 +10000 的 key
    if not card_slot_candidate.all_card_candidate_containers_zombie[card_key].card.is_choosed_pre_card:
        card_slot_candidate.all_card_candidate_containers_zombie[card_key].card._on_button_pressed()
```

### 6. 被移除的文件/代码

| 移除项 | 说明 |
|--------|------|
| `Z031Charm` 枚举值 | 从 `character_registry.gd` 和 `global_game_state.gd` 中移除 |
| `ZombieCards3` 场景节点 | 从 `all_cards.tscn` 中移除（~277行） |
| `card.gd` 中的 `apply_charm_filter()` | 不再使用 shader 滤镜 |
| `shaders/my_shader/charm.gdshader` | 不再需要（保留备用） |
| `shader_material/charm.tres` | 不再需要（保留备用） |

---

## 数据流

```
curr_zombie (31个僵尸类型)
  │
  ▼
_init_card_slot_candidate_zombie()
  │
  ├── 普通僵尸页：直接显示 all_zombie_card_prefabs 的卡片
  │
  └── 魅惑页：for each curr_zombie
        │
        ├── orig_card.character_static.modulate = Color(1,0.5,1)
        ├── orig_card.character_static.scale.x *= -1
        ├── charm_card = orig_card.duplicate()
        ├── charm_card.is_charm_card = true
        └── 存储到字典 key = card_id + 10000

玩家选择魅惑卡片
  │
  ▼
click_cell() / _click_cell_column()
  │
  ├── create_norm_zombie()  正常创建僵尸
  └── zombie.be_hypno()     原版魅惑效果
```

---

## 注意事项

1. **`@onready` 变量陷阱**：`character_static` 是 `@onready var`，duplicate 出来的节点未加入场景树，访问会报 `Nil`。必须在原卡上设置属性后再 duplicate。

2. **字典 key 冲突**：用 `card_id + 10000` 区分普通卡和魅惑卡，存入同一个 `all_card_candidate_containers_zombie` 字典。

3. **魅惑页始终可见**：魅惑页不参与普通页面的翻页逻辑，在循环结束后单独设置 `visible = true`。

4. **复用原版系统**：不引入自定义 shader，完全复用 `body_character.gd` 的 `HypnoColor` modulate 系统和 `character_000_base.gd` 的 `be_hypno()` 信号系统。

5. **ghost 预览继承**：选卡时的虚影（`_characte_static = card.character_static.duplicate()`）会自动继承 `modulate` 值，无需额外处理。

---

## 豌豆僵尸碰撞层修复

### 问题

豌豆僵尸发射的豌豆子弹无法命中任何目标（植物或僵尸）。

### 根因：碰撞层不匹配

| 实体 | 节点 | 层 |
|---|---|---|
| 豌豆子弹 | `Area2DAttack.collision_mask` | 513 = 层1 + 层10 |
| 植物 | `HurtBoxReal.collision_layer` | 256 = 层9 |
| 僵尸 | `HurtBoxReal.collision_layer` | 512 = 层10 |
| 魅惑僵尸 | `HurtBoxReal.collision_layer` | 1024 = 层11 |

子弹 mask=513 包含层10（僵尸），但**不包含层9（植物）**和层11（魅惑僵尸）。Godot 的 `area_entered` 信号要求 mask 与目标 layer 有交集才会触发，因此子弹永远检测不到植物。

子弹碰撞回调 `_on_area_2d_attack_area_entered` 中的阵营过滤逻辑是正确的，但因为信号根本不会触发，所以过滤代码从未执行。

### 修复

在 `zombie_031_pea_zombie.gd` 的 `_on_技能冷却好_timeout()` 中，`add_child` 后设置碰撞 mask：

```gdscript
# 层9(植物) + 层10(僵尸) + 层11(魅惑僵尸)
bullet.area_2d_attack.collision_mask = 256 + 512 + 1024
```

注意 `area_2d_attack` 是 `@onready` 变量，必须在 `add_child` 之后才能访问。

### 修复后效果

| 场景 | 子弹阵营 | 检测层 | 阵营过滤 | 结果 |
|---|---|---|---|---|
| 未魅惑打植物 | Zombie | 层9+10+11 | `bullet_camp==Zombie` + `enemy is Plant` → 不跳过 | 命中植物 ✓ |
| 魅惑打僵尸 | Plant | 层9+10+11 | `bullet_camp==Plant` + `enemy is Zombie` → 不跳过 | 命中僵尸 ✓ |
| 未魅惑打魅惑僵尸 | Zombie | 层9+10+11 | `bullet_camp==Zombie` + `enemy is Zombie` → 跳过 | 不命中（正确） |
| 魅惑打植物 | Plant | 层9+10+11 | `bullet_camp==Plant` + `enemy is Plant` → 跳过 | 不命中（正确） |
