extends Plant000Base
class_name Plant050SuperPea

@onready var attack_component: AttackComponentBulletPultBase = $AttackComponent
var helmet: Sprite2D

## 急速散射触发概率 (0.0 ~ 1.0)
@export var burst_chance: float = 0.02
## 急速散射后概率提升
@export var burst_chance_upgraded: float = 0.06
## 散射子弹数量
@export var burst_bullet_count: int = 210
## 散射角度范围（度）
@export var burst_spread_angle: float = 15.0
## 散射射速（每颗间隔秒数）
@export var burst_fire_interval: float = 0.01
## 升级后头盔贴图
var helmet_upgraded_texture: Texture2D = preload("res://assets/reanim/SuperPea/default/头盔3.png")

## 初始化正常出战角色信号连接
func ready_norm_signal_connect():
	super()
	signal_update_speed.connect(attack_component.owner_update_speed)
	attack_component.on_shoot_bullet = _on_shoot_bullet
	helmet = $Body/BodyCorrect/Anim_idle/HeadCorrect/Node/GatlingPea_helmet

## 攻击回调，返回 true 表示已处理（替换默认发射）
func _on_shoot_bullet() -> bool:
	## 急速散射
	if randf() < burst_chance:
		burst_chance = burst_chance_upgraded
		_burst_fire()
		return true
	return false

## 急速散射：210颗豌豆，散射角度 burst_spread_angle ~ -burst_spread_angle
func _burst_fire():
	var bullet_scene = Global.bullet_registry.get_bullet_scenes(attack_component.attack_bullet_type)
	var marker: Marker2D = attack_component.markers_2d_bullet[0]
	var base_pos = attack_component.bullets.to_local(marker.global_position)
	var base_dir = Vector2.RIGHT

	for i in range(burst_bullet_count):
		var angle_offset = randf_range(-burst_spread_angle, burst_spread_angle)
		var rad = deg_to_rad(angle_offset)
		var dir = base_dir.rotated(rad)

		var bullet: Bullet000Base = bullet_scene.instantiate()
		var bullet_paras = {
			Bullet000NormBase.E_InitParasAttr.IsActivateLane : true,
			Bullet000NormBase.E_InitParasAttr.BulletLane : lane,
			Bullet000NormBase.E_InitParasAttr.Position : base_pos,
			Bullet000NormBase.E_InitParasAttr.Direction : dir,
			Bullet000NormBase.E_InitParasAttr.CanAttackPlantState : 1,
			Bullet000NormBase.E_InitParasAttr.CanAttackZombieState : 1,
		}
		bullet.init_bullet(bullet_paras)
		attack_component.bullets.add_child(bullet)
		attack_component.play_throw_sfx()
		if i < burst_bullet_count - 1:
			await get_tree().create_timer(burst_fire_interval).timeout

	if is_instance_valid(helmet):
		helmet.texture = helmet_upgraded_texture
