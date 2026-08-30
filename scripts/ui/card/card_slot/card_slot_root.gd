extends Control
class_name CardSlotRoot

## 卡片
var curr_cards:Array[Card]
## 铲子
@onready var ui_shovel: UIShovel = %UIShovel

## 快捷键
@warning_ignore("unused_parameter")
func _unhandled_key_input(event):
	## 铲子快捷键
	if Input.is_action_just_pressed("ShortcutKeys_Shovel"):
		if ui_shovel.visible:
			ui_shovel._on_button_pressed()
		return
	## 数字快捷键 1-0（卡槽1-10）
	for i in range(1, 11):
		if Input.is_action_just_pressed("ShortcutKeys_Card" + str(i)):
			var card_i = i - 1
			if card_i < curr_cards.size():
				curr_cards[card_i]._on_button_pressed()
			else:
				return
	## 字母快捷键 a-i（卡槽11-19），跳过f（铲子占用）
	var letter_keys = ["a", "b", "c", "d", "e", "g", "h", "i"]
	for i in range(letter_keys.size()):
		if Input.is_action_just_pressed("ShortcutKeys_CardLetter" + letter_keys[i].to_upper()):
			var card_i = 10 + i
			if card_i < curr_cards.size():
				curr_cards[card_i]._on_button_pressed()
			else:
				return
