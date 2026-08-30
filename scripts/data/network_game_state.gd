extends Resource
class_name NetworkGameState

## 网络游戏状态资源

## 游戏模式
var game_mode: String = ""

## 选中的地图
var selected_map: String = ""

## 选中的阵营
var selected_faction: String = ""

## 玩家准备状态
var players_ready: Dictionary = {}

## 游戏是否已开始
var game_started: bool = false

## 创建新的网络游戏状态
static func create_new(game_mode: String, map_name: String, faction_name: String) -> NetworkGameState:
	var state = NetworkGameState.new()
	state.game_mode = game_mode
	state.selected_map = map_name
	state.selected_faction = faction_name
	return state

## 添加玩家准备状态
func set_player_ready(player_id: int, ready: bool) -> void:
	if not players_ready.has(player_id):
		players_ready[player_id] = {}
	players_ready[player_id]["ready"] = ready
	players_ready[player_id]["name"] = "Player_%d" % player_id

## 检查玩家是否准备就绪
func is_player_ready(player_id: int) -> bool:
	if not players_ready.has(player_id):
		return false
	return players_ready[player_id].get("ready", false)

## 获取所有准备就绪的玩家ID
func get_ready_players() -> Array[int]:
	var ready_players: Array[int] = []
	for player_id in players_ready:
		if is_player_ready(player_id):
			ready_players.append(player_id)
	return ready_players

## 获取未准备就绪的玩家ID
func get_unready_players() -> Array[int]:
	var unready_players: Array[int] = []
	for player_id in players_ready:
		if not is_player_ready(player_id):
			unready_players.append(player_id)
	return unready_players

## 获取玩家数量
func get_player_count() -> int:
	return players_ready.size()

## 获取准备就绪的玩家数量
func get_ready_count() -> int:
	return get_ready_players().size()

## 获取未准备就绪的玩家数量
func get_unready_count() -> int:
	return get_unready_players().size()

## 获取所有玩家信息
func get_all_players_info() -> Dictionary:
	return players_ready

## 复制当前状态
func duplicate_state() -> NetworkGameState:
	var new_state = NetworkGameState.new()
	new_state.game_mode = self.game_mode
	new_state.selected_map = self.selected_map
	new_state.selected_faction = self.selected_faction
	new_state.game_started = self.game_started
	new_state.players_ready = self.players_ready.duplicate()
	return new_state
