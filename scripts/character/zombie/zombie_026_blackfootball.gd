extends Node2D
#@onready var = preload() as Texture2D
var Zombie_football_leftleg_lower = preload("res://assets/reanim/Black_football_leftleg_lower.png") #
var Zombie_football_rightleg_lower = preload("res://assets/reanim/Black_football_rightleg_lower.png") #
var Zombie_football_upperbody2 = preload("res://assets/reanim/Black_football_upperbody2.png") #
var Zombie_football_upperbody = preload("res://assets/reanim/Black_football_upperbody.png") #
var Zombie_football_upperbody3 = preload("res://assets/reanim/Black_football_upperbody3.png") #
var Zombie_football_leftarm_hand = preload("res://assets/reanim/Black_football_leftarm_hand.png") #
var Zombie_football_rightarm_hand = preload("res://assets/reanim/Black_football_rightarm_hand.png") #

func _ready() -> void:
	$Zombie_football_leftleg_lower.texture = Zombie_football_leftleg_lower
	$Zombie_football_rightleg_lower.texture = Zombie_football_rightleg_lower
	$Zombie_football_upperbody2.texture = Zombie_football_upperbody2
	$Zombie_football_upperbody.texture = Zombie_football_upperbody
	$Zombie_football_upperbody3.texture = Zombie_football_upperbody3
	$Zombie_football_leftarm_hand.texture = Zombie_football_leftarm_hand
	$Zombie_football_rightarm_hand.texture = Zombie_football_rightarm_hand
