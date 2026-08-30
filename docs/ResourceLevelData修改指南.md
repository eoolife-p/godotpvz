# ResourceLevelData 关卡修改指南

> 基于 `scripts/resources/level/level_data.gd` (432行)
> 本文档覆盖所有可编辑参数、枚举值、数据流和常见场景。

---

## 1. 快速开始

每个关卡对应一个 `.tres` 文件，位于 `resources/level_date_resource/` 下。

**新建关卡：**
1. 在 Godot 编辑器中 `res://` 面板右键 → New Resource → 选择 `ResourceLevelData`
2. 保存到对应模式文件夹（如 `mode_adventure/`）
3. 在选关界面的 `ChooseLevelButton` 节点中引用该 `.tres`

**修改关卡：**
双击 `.tres` 文件，在 Inspector 面板直接编辑属性。

---

## 2. 完整参数速查表

### 2.1 选关数据（运行时自动设置）

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `game_mode` | `MainSceneRegistry.MainScenes` | Null | 游戏模式，运行时由选关按钮设置 |
| `level_page` | `int` | 0 | 关卡所在页面 |
| `level_id` | `String` | "test" | 关卡唯一标识符 |
| `save_game_name` | `String` | 自动拼接 | 多轮存档文件名（无后缀） |

### 2.2 关卡背景

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `game_sences` | `MainSceneRegistry.MainScenes` | MainGameFront | 游戏场景类型 |
| `game_round` | `int` | 1 | 多轮游戏轮次，-1=无尽 |
| `game_BG` | `ConstLevelData.GameBg` | FrontDay | 背景图片 |
| `game_BGM` | `ConstLevelData.GameBGM` | FrontDay | 背景音乐 |
| `is_fog` | `bool` | false | 是否有雾 |
| `is_rain` | `bool` | false | 是否有雨 |
| `is_day` | `bool` | true | 是否白天（影响蘑菇睡觉） |
| `is_day_sun` | `bool` | true | 是否天降阳光 |
| `is_lawn_mover` | `bool` | true | 是否有小推车 |
| `is_zombie_can_home` | `bool` | true | 僵尸是否能进房 |
| `all_pre_plant_data` | `Array[PrePlantResource]` | [] | 预种植植物列表 |

### 2.3 关卡流程

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `look_show_zombie` | `bool` | true | 开局查看展示僵尸 |
| `can_choosed_card` | `bool` | true | 是否可以选择卡片 |
| `crazy_dave_dialog` | `CrazyDaveDialogResource` | null | 戴夫对话资源 |

### 2.4 出怪参数

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `monster_mode` | `E_MonsterMode` | Norm | 出怪模式 |
| `is_mini_zombie` | `bool` | false | 小僵尸模式 |
| `zombie_multy` | `int` | 1 | 出怪倍率 |
| `max_wave` | `int` | 30 | 每轮波次（每10波1旗帜） |
| `zombie_refresh_types` | `Array[ZombieType]` | [Z001,Z003,Z004,Z005] | 僵尸刷新列表 |
| `is_bungi` | `bool` | false | 是否有蹦极僵尸 |
| `range_num_bungi` | `Vector2i` | (3,5) | 大波蹦极数量范围 |
| `zombie_multy_hammer` | `int` | 1 | 墓碑出怪倍率 |
| `max_wave_hammer_zombie` | `int` | 10 | 锤僵尸波数 |
| `speed_zombie_init` | `float` | 1.0 | 初始僵尸速度 |
| `speed_zombie_add` | `float` | 0.15 | 每波速度提升 |
| `speed_zombie_max` | `float` | 2.0 | 速度上限 |
| `is_have_tombston` | `bool` | false | 墓碑是否生成僵尸 |
| `init_tombstone_num` | `int` | 0 | 初始墓碑数量 |

### 2.5 卡片参数

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `card_mode` | `E_CardMode` | Norm | 卡槽模式 |
| `is_seed_rain` | `bool` | false | 是否种子雨 |
| `max_choosed_card_num` | `int` (1-15) | 10 | 最大卡槽数 |
| `start_sun` | `int` | 50 | 开局阳光 |
| `pre_choosed_card_list_plant` | `Array[PlantType]` | [] | 预选植物卡片 |
| `pre_choosed_card_list_zombie` | `Array[ZombieType]` | [] | 预选僵尸卡片 |
| `all_card_plant_type_probability` | `Dict[PlantType,int]` | {} | 传送带植物概率 |
| `all_card_zombie_type_probability` | `Dict[ZombieType,int]` | {} | 传送带僵尸概率 |
| `card_order_plant` | `Dict[int,PlantType]` | {} | 传送带植物固定顺序 |
| `card_order_zombie` | `Dict[int,ZombieType]` | {} | 传送带僵尸固定顺序 |
| `create_new_card_speed` | `float` | 1 | 传送带出卡速度 |
| `all_card_plant_type_probability_seed_rain` | `Dict[PlantType,int]` | {} | 种子雨植物概率 |
| `all_card_zombie_type_probability_seed_rain` | `Dict[ZombieType,int]` | {} | 种子雨僵尸概率 |
| `card_order_plant_seed_rain` | `Dict[int,PlantType]` | {} | 种子雨植物固定顺序 |
| `card_order_zombie_seed_rain` | `Dict[int,ZombieType]` | {} | 种子雨僵尸固定顺序 |
| `is_mode_column` | `bool` | false | 柱子模式 |
| `is_shovel` | `bool` | true | 是否有铲子 |

### 2.6 罐子参数

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `is_pot_mode` | `bool` | false | 是否罐子模式 |
| `pot_mode` | `E_PotMode` | Null | 罐子生成模式 |
| `pot_col_range` | `Vector2i` | (4,9) | 生成罐子的列范围 |
| `is_can_look_random_res_pot` | `bool` | false | 能否查看随机罐子结果 |
| `is_save_plant_on_pot_mode` | `bool` | false | 罐子模式保存植物 |
| `weight_res_fiexd` | `float` (0-1) | 1.0 | 固定/随机权重比 |
| `candidate_plant_pot` | `Dict[PlantType,int]` | {} | 权重随机植物候选 |
| `candidate_zombie_pot` | `Dict[ZombieType,int]` | {} | 权重随机僵尸候选 |
| `weight_pot_type` | `Vector3i` | (6,2,2) | 罐子类型权重 (植物:僵尸:空) |
| `random_pot_plant` | `Dict[PlantType,int]` | {} | 固定模式-随机位置植物 |
| `random_pot_zombie` | `Dict[ZombieType,int]` | {} | 固定模式-随机位置僵尸 |
| `plant_pot` | `Dict[PlantType,int]` | {} | 固定模式-固定位置植物 |
| `zombie_pot` | `Dict[ZombieType,int]` | {} | 固定模式-固定位置僵尸 |
| `random_pot_num_on_fixed_mode` | `Vector3i` | (0,0,0) | 固定模式额外随机罐子数 |

### 2.7 我是僵尸模式

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `is_zombie_mode` | `bool` | false | 是否我是僵尸模式 |
| `plant_col_on_zombie_mode` | `int` | 4 | 植物列数 |
| `all_plants_weight_on_zombie_mode` | `Dict[PlantType,int]` | {} | 植物权重 |
| `all_must_plants_on_zombie_mode` | `Dict[PlantType,int]` | {} | 必出植物 |

### 2.8 游戏物品参数

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `is_bowling_stripe` | `bool` | false | 保龄球红线 |
| `plant_cell_col_j` | `int` | 2 | 红线列位置（0开始） |
| `plant_cell_can_use` | `Dict[String,bool]` | 见下 | 格子使用权限 |
| `is_hammer` | `bool` | false | 锤子模式 |

`plant_cell_can_use` 默认值：
```gdscript
{
    "left_can_plant": true,    # 左侧可种植
    "right_can_plant": true,   # 右侧可种植
    "left_can_zombie": true,   # 左侧可出僵尸
    "right_can_zombie": true,  # 右侧可出僵尸
}
```

---

## 3. 枚举值速查

### 3.1 GameBg（背景）

| 值 | 名称 | 说明 |
|----|------|------|
| 0 | FrontDay | 前院白天 |
| 1 | FrontNight | 前院夜晚 |
| 2 | Pool | 泳池 |
| 3 | Fog | 迷雾 |
| 4 | Roof | 屋顶 |

### 3.2 GameBGM（音乐）

| 值 | 名称 |
|----|------|
| 0 | FrontDay |
| 1 | FrontNight |
| 2 | Pool |
| 3 | Fog |
| 4 | Roof |
| 5 | MiniGame |
| 6 | Boss |
| 7 | Puzzle |

### 3.3 E_MonsterMode（出怪模式）

| 值 | 名称 | 说明 |
|----|------|------|
| 0 | Null | 不出怪（测试用） |
| 1 | Norm | 正常出怪 |
| 2 | HammerZombie | 锤僵尸（墓碑出怪） |

### 3.4 E_CardMode（卡槽模式）

| 值 | 名称 | 说明 |
|----|------|------|
| 0 | Null | 无卡槽 |
| 1 | Norm | 正常选卡 |
| 2 | ConveyorBelt | 传送带 |
| 3 | Coin | 金币卡槽（雪人） |

### 3.5 E_PotMode（罐子模式）

| 值 | 名称 | 说明 |
|----|------|------|
| 0 | Null | 无 |
| 1 | Weight | 权重随机 |
| 2 | Fixd | 固定生成随机位置 |

### 3.6 PlantType（植物类型）

| 值 | 名称 | 值 | 名称 |
|----|------|----|------|
| 0 | Null | 25 | SeaShroom |
| 1 | PeaShooterSingle | 26 | Plantern |
| 2 | SunFlower | 27 | Cactus |
| 3 | CherryBomb | 28 | Blover |
| 4 | WallNut | 29 | SplitPea |
| 5 | PotatoMine | 30 | StarFruit |
| 6 | SnowPea | 31 | Pumpkin |
| 7 | Chomper | 32 | MagnetShroom |
| 8 | PeaShooterDouble | 33 | CabbagePult |
| 9 | PuffShroom | 34 | FlowerPot |
| 10 | SunShroom | 35 | CornPult |
| 11 | FumeShroom | 36 | CoffeeBean |
| 12 | GraveBuster | 37 | Garlic |
| 13 | HypnoShroom | 38 | UmbrellaLeaf |
| 14 | ScaredyShroom | 39 | MariGold |
| 15 | IceShroom | 40 | MelonPult |
| 16 | DoomShroom | 41 | GatlingPea |
| 17 | LilyPad | 42 | TwinSunFlower |
| 18 | Squash | 43 | GloomShroom |
| 19 | ThreePeater | 44 | Cattail |
| 20 | TangleKelp | 45 | WinterMelon |
| 21 | Jalapeno | 46 | GoldMagnet |
| 22 | Caltrop | 47 | SpikeRock |
| 23 | TorchWood | 48 | CobCannon |
| 24 | TallNut | 999 | Imitater |
| | | 1000 | Sprout |
| | | 1001-1003 | Bowling系列 |

### 3.7 ZombieType（僵尸类型）

| 值 | 名称 | 值 | 名称 |
|----|------|----|------|
| 0 | Null | 16 | Jackbox |
| 1 | Z001Norm | 17 | Balloon |
| 2 | Z002Flag | 18 | Digger |
| 3 | Z003Cone | 19 | Pogo |
| 4 | Z004PoleVaulter | 20 | Yeti |
| 5 | Z005Bucket | 21 | Bungi |
| 6 | Z006Paper | 22 | Ladder |
| 7 | Z007ScreenDoor | 23 | Catapult |
| 8 | Z008Football | 24 | Gargantuar |
| 9 | Z009Jackson | 25 | Imp |
| 10 | Z010Dancer | 26 | BlackFootball |
| 11 | Z011Duckytube | 27 | AngerNorm |
| 12 | Z012Snorkle | 28 | ConeDancer |
| 13 | Z013Zamboni | 29 | BlueFootball |
| 14 | Z014Bobsled | 30 | RedEyeGargantuar |
| 15 | Z015Dolphinrider | 1001 | BobsledSingle |

---

## 4. 常见场景配置示例

### 4.1 标准白天关卡（冒险1-1）

```tres
[resource]
script = ExtResource("...")  # ResourceLevelData 脚本
# 背景：默认 FrontDay，不需要额外设置
# 音乐：默认 FrontDay
# 出怪
zombie_refresh_types = Array[int]([1, 3, 4, 5])
# 卡片
max_choosed_card_num = 15
start_sun = 50
```

### 4.2 夜晚关卡（冒险2-1）

```tres
[resource]
script = ExtResource("...")
game_BG = 1          # FrontNight
game_BGM = 1         # FrontNight
is_day = false       # 蘑菇不睡觉
is_day_sun = false   # 无天降阳光
```

### 4.3 泳池关卡

```tres
[resource]
script = ExtResource("...")
game_BG = 2          # Pool
game_BGM = 2         # Pool
```

### 4.4 迷雾关卡

```tres
[resource]
script = ExtResource("...")
game_BG = 3          # Fog
game_BGM = 3         # Fog
is_fog = true
```

### 4.5 屋顶关卡（带蹦极）

```tres
[resource]
script = ExtResource("...")
game_BG = 4          # Roof
game_BGM = 4         # Roof
is_bungi = true
range_num_bungi = Vector2i(3, 5)
# 预种植花盆
all_pre_plant_data = Array[Resource]([
    ExtResource("...")  # PrePlantResource: plant_type=34(FlowerPot), plant_cell_pos=Vector2i(1,0)
])
```

### 4.6 传送带迷你游戏（保龄球）

```tres
[resource]
script = ExtResource("...")
game_BGM = 5             # MiniGame
is_day_sun = false       # 传送带无天降阳光
look_show_zombie = false
can_choosed_card = false  # 传送带禁止选卡
zombie_multy = 3
max_wave = 20
card_mode = 2            # ConveyorBelt
max_choosed_card_num = 15
# 传送带植物概率（值=权重）
all_card_plant_type_probability = Dictionary[int, int]({
    1001: 2,  # WallNutBowling
    1002: 1,  # WallNutBowlingBomb
    1003: 1   # WallNutBowlingBig
})
# 固定出卡顺序
card_order_plant = Dictionary[int, int]({
    0: 1001,
    1: 1002,
    2: 1003
})
# 保龄球红线
is_bowling_stripe = true
plant_cell_can_use = Dictionary[String, bool]({
    "left_can_plant": true,
    "left_can_zombie": true,
    "right_can_plant": false,
    "right_can_zombie": true
})
```

### 4.7 我是僵尸模式

```tres
[resource]
script = ExtResource("...")
game_BG = 1              # FrontNight
game_BGM = 7             # Puzzle
is_day = false
is_day_sun = false
is_lawn_mover = false
look_show_zombie = false
can_choosed_card = false
start_sun = 300          # 初始阳光（用于放置僵尸）
# 预选僵尸
pre_choosed_card_list_zombie = Array[int]([1, 3, 5])
# 我是僵尸模式参数
is_zombie_mode = true
plant_col_on_zombie_mode = 5
all_plants_weight_on_zombie_mode = Dictionary[int, int]({
    1: 1,  # PeaShooter
    2: 1   # SunFlower
})
# 保龄球红线（右侧出僵尸）
is_bowling_stripe = true
plant_cell_col_j = 4
plant_cell_can_use = Dictionary[String, bool]({
    "left_can_plant": false,
    "left_can_zombie": false,
    "right_can_plant": false,
    "right_can_zombie": true
})
```

### 4.8 无尽生存模式

```tres
[resource]
script = ExtResource("...")
max_wave = 100  # 大量波次
zombie_refresh_types = Array[int]([1, 3, 4, 5, 8, 9, 22, 24])
# 包含：普通、路障、撑杆、铁桶、足球、读报、扶梯、巨人
```

### 4.9 无尽模式（game_round=-1）

```tres
[resource]
script = ExtResource("...")
game_round = -1          # 无尽模式
max_wave = 100
zombie_refresh_types = Array[int]([1, 3, 4, 5, 8, 9, 24])
```

### 4.10 罐子模式（权重随机）

```tres
[resource]
script = ExtResource("...")
game_BG = 1              # FrontNight
game_BGM = 7             # Puzzle
is_day = false
is_pot_mode = true
pot_mode = 1             # Weight
pot_col_range = Vector2i(4, 9)
weight_pot_type = Vector3i(6, 2, 2)  # 植物:僵尸:空 = 6:2:2
# 候选植物（权重）
candidate_plant_pot = Dictionary[int, int]({
    1: 1,   # PeaShooter
    4: 1,   # WallNut
    15: 1   # IceShroom
})
# 候选僵尸（权重）
candidate_zombie_pot = Dictionary[int, int]({
    1: 1,   # Norm
    3: 1,   # Cone
    5: 1    # Bucket
})
```

### 4.11 罐子模式（固定生成）

```tres
[resource]
script = ExtResource("...")
is_pot_mode = true
pot_mode = 2             # Fixd
# 固定位置植物罐子
plant_pot = Dictionary[int, int]({
    4: 3,   # 3个WallNut
    15: 2   # 2个IceShroom
})
# 固定位置僵尸罐子
zombie_pot = Dictionary[int, int]({
    1: 2,   # 2个Norm
    3: 1    # 1个Cone
})
# 随机位置植物罐子
random_pot_plant = Dictionary[int, int]({
    1: 2    # 2个随机位置PeaShooter
})
# 随机位置僵尸罐子
random_pot_zombie = Dictionary[int, int]({
    5: 1    # 1个随机位置Bucket
})
```

---

## 5. init_para() 自动修正规则

游戏启动时 `init_para()` 会自动执行以下修正，编辑 `.tres` 时无需手动处理：

| 规则 | 说明 |
|------|------|
| 传送带禁止选卡 | `card_mode != Norm` 时自动设 `can_choosed_card = false` |
| 传送带禁止天降阳光 | `card_mode = ConveyorBelt` 时自动设 `is_day_sun = false` |
| 预选卡补全 | `pre_choosed_card_list` 不足时用 `0` 补齐到 `max_choosed_card_num` |
| 僵尸白名单过滤 | `zombie_refresh_types` 中不在当前场景白名单的僵尸会被移除 |
| Z021Bungi 自动转换 | 列表中写 `Z021Bungi` 会自动改为 `is_bungi = true` |
| 罐子列范围修正 | `pot_col_range.x > y` 时自动交换 |
| 我是僵尸模式 | 自动设 `is_zombie_can_home = false` |

---

## 6. 数据流向

```
ResourceLevelData (.tres)
  │
  ├── MainGameManager.game_para (持有引用)
  │     ├── init_para()          → 验证/修正参数
  │     ├── BackgroundManager    → game_BG, is_fog, is_rain
  │     ├── DaySunsManager       → is_day_sun
  │     ├── CardManager          → card_mode, max_choosed_card_num, start_sun
  │     ├── ZombieWaveManager    → max_wave, is_have_tombston
  │     ├── ZombieWaveCreateManager → zombie_multy, zombie_refresh_types, is_bungi
  │     ├── HammerZombieManager  → zombie_multy_hammer, speed_zombie_*
  │     ├── TombStoneManager     → init_tombstone_num
  │     ├── Pool                 → game_BG, is_rain
  │     └── CardSlot*            → 卡槽相关参数
  │
  ├── Global.game_para (全局引用)
  │
  └── ChooseLevelButton.curr_level_data_game_para (选关界面引用)
```

---

## 7. 注意事项

1. **不要在 `zombie_refresh_types` 中写 `Z021Bungi`**，应使用 `is_bungi = true`
2. **传送带模式**下 `can_choosed_card` 和 `is_day_sun` 会被自动覆盖为 `false`
3. **预选卡**不足 `max_choosed_card_num` 时会自动用 `0` 补齐
4. **`game_round = -1`** 表示无尽模式，不要用其他数字表示无尽
5. **罐子固定模式**下 `pot_num_on_fixed_mode` 会自动计算所有罐子总数
6. **僵尸白名单**会在运行时根据 `game_sences` 自动过滤无效僵尸
7. **存档路径**格式：`user://<用户名>/main_game/<game_mode>_<level_page>_<level_id>.tres`
