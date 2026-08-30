extends TextureButton

var start_pos := Vector2.ZERO
var end_pos := Vector2.ZERO
var speed := 1000.0  # 像素/秒
var t := 0.0
var moving := false
var node
func start_move(from: Vector2, to: Vector2):
	if moving :
		return
	start_pos = from
	end_pos = to
	t = 0.0
	moving = true
	node.position = start_pos

func _process(delta):
	if moving:
		t += delta * speed / start_pos.distance_to(end_pos)
		
		if t >= 1.0:
			node.position = end_pos
			moving = false
		else:
			node.position = start_pos.lerp(end_pos, t)
			
func _on_button_down() -> void:
	node = $"../../BG_Right"
	#node.position -= Vector2(266,0)
	start_move(node.position,node.position+Vector2(-800+266,0))
	pass # Replace with function body.

func _ZMH_on_ready() -> void:
	$"../../BG_Right".position.x = 74.0
	modulate.a = 0
	pass # Replace with function body.

func _on_ZMH_button_down() -> void:
	node = $"../../BG_Right"
	start_move(node.position,node.position+Vector2(800-266,0))
	pass # Replace with function body.
