extends Control
class_name AlmanacZombieCard

@onready var almanac_zombie_card_bg: TextureRect = $AlmanacZombieCardBg

var zombie_type:CharacterRegistry.ZombieType

signal signal_card_click

func _ready() -> void:
	var zombie_card:Card = AllCards.all_zombie_card_prefabs[zombie_type]
	var character_static:Node2D = zombie_card.character_static.duplicate()
	almanac_zombie_card_bg.add_child(character_static)
	var target_scale = Vector2(2, 2)
	var target_position = Vector2(40, 50)
	match zombie_type:
		CharacterRegistry.ZombieType.Z026BlackFootball:
			target_scale = Vector2(2.3, 2.3)
		CharacterRegistry.ZombieType.Z025Imp:
			target_scale = Vector2(3 ,3)
			target_position = Vector2(40, 20)
	character_static.scale = target_scale#Vector2(1.6, 1.6)
	character_static.position = target_position

func init_almanac_zombie_card(curr_zombie_type:CharacterRegistry.ZombieType):
	zombie_type = curr_zombie_type

func _on_button_pressed() -> void:
	signal_card_click.emit()
