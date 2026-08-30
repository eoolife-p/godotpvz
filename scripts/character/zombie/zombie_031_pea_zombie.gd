extends Zombie000Base
class_name Zombie031PeaZombie

@onready var anim_innerarm: Node2D = $Body/BodyCorrect/Anim_innerarm
@onready var zombie_outerarm_upper: Node2D = $Body/BodyCorrect/Zombie_outerarm_upper
@onready var _技能倒计时: Timer = $技能
@onready var _子弹发射点: Marker2D = $Body/BodyCorrect/Anim_head/Anim_head1/Anim_stem/stem_correct/Marker2DBullet
@onready var _植物头动画: AnimationPlayer = $Body/BodyCorrect/Anim_head/AnimationPlayer
@export_group("动画状态")
## 动画状态（僵尸有某类动画有多种）
@export var idle_status := 1
@export var walk_status := 1
@export var death_status := 1

@export_subgroup("最大动画状态")
@export var idle_status_max := 2
@export var walk_status_max := 2
@export var death_status_max := 2

@export_group("普僵初始化精灵节点")
@export var init_sprite_random:Array[Node2D]

## 海草精灵节点
@onready var sprite_seaweed:Array[Sprite2D] = [
	$Body/BodyCorrect/Anim_head/Anim_head1/ZombieSeaweed3,
	$Body/BodyCorrect/Zombie_duckytube/Zombie_duckytube/ZombieSeaweed,
	$Body/BodyCorrect/Zombie_duckytube/Zombie_duckytube/ZombieSeaweed2,
	$Body/BodyCorrect/Zombie_outerarm_upper/Zombie_outerarm_upper/ZombieSeaweed4,
	$Body/BodyCorrect/Anim_head/Anim_head1/ZombieSeaweed2,
]
## 铁桶海草精灵
@onready var sprite_seaweed_bucket: Sprite2D = $Body/BodyCorrect/Anim_bucket/Anim_bucket/ZombieSeaweed4

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	_random_anim_status()
	_random_sprit_appear()
	if is_seaweed:
		sprite_seaweed.shuffle()
		var pick3 = sprite_seaweed.slice(0, 3)
		for s in pick3:
			s.visible = true
		sprite_seaweed_bucket.visible = true
	## 连接速度信号，冰冻/黄油等定身时暂停冷却
	signal_update_speed.connect(_on_update_speed)
	## 掉头时停止发射
	hp_stage_change_component.signal_hp_stage_change.connect(_on_hp_stage_change)
	if not is_show:
		_技能倒计时.start()
		

## 速度变化时暂停/恢复冷却
func _on_update_speed(speed_product: float) -> void:
	if not _技能倒计时.is_stopped():
		if speed_product == 0:
			_技能倒计时.paused = true
		else:
			_技能倒计时.paused = false

## 掉头时停止发射（掉手不影响）
func _on_hp_stage_change(stage: int) -> void:
	if stage >= 1:
		_技能倒计时.stop()

## 随机选择动画状态种类
func _random_anim_status():
	idle_status = randi_range(1, idle_status_max)
	walk_status = randi_range(1, walk_status_max)
	death_status = randi_range(1, death_status_max)

func _random_sprit_appear():
	for sprite in init_sprite_random:
		sprite.visible = [true, false].pick_random()

## 死亡动画开始时,将里面的胳膊显示(旗帜\铁门)
func anim_death_start():
	anim_innerarm.visible = true


func _on_技能冷却好_timeout() -> void:
	if is_show:
		return
	_植物头动画.play("射子弹")
	await _植物头动画.animation_finished
	_植物头动画.stop()
	_技能倒计时.start()
func _发射子弹(): #动画调用
	var bullet: Bullet000Base = Global.bullet_registry.get_bullet_scenes(
		BulletRegistry.BulletType.Bullet001Pea
	).instantiate()
	var pos = Global.main_game.bullets.to_local(_子弹发射点.global_position)
	var direct = Vector2.LEFT
	## 未魅惑打植物，魅惑打僵尸
	if self.is_hypno:
		direct = Vector2.RIGHT
		bullet.bullet_camp = CharacterRegistry.CharacterType.Plant
	else:
		bullet.bullet_camp = CharacterRegistry.CharacterType.Zombie
	var bullet_paras = {
		Bullet000NormBase.E_InitParasAttr.Position: pos,
		Bullet000NormBase.E_InitParasAttr.Direction: direct,
		Bullet000NormBase.E_InitParasAttr.BulletLane: self.lane,
		Bullet000NormBase.E_InitParasAttr.IsActivateLane: true,
		Bullet000NormBase.E_InitParasAttr.CanAttackPlantState: 1,
		Bullet000NormBase.E_InitParasAttr.CanAttackZombieState: 1,
	}
	bullet.init_bullet(bullet_paras)
	Global.main_game.bullets.add_child(bullet)
	SoundManager.play_character_SFX(&"Throw")
	## 修复碰撞层：area_2d_attack是@onready，需在add_child后设置
	## 豌豆子弹默认mask=513(层1+10)只检测僵尸HurtBoxReal(层10)
	## 需加入植物HurtBoxReal(层9=256)和魅惑僵尸HurtBoxReal(层11=1024)
	bullet.area_2d_attack.collision_mask = 256 + 512 + 1024  # 层9+层10+层11
	pass
