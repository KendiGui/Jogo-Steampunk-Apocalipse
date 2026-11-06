extends Node2D
## Arena de teste. Liga a rede e, no host, cria um jogador para cada peer.
##
## Os clientes não criam jogadores: o nó PlayerSpawner (filho desta cena)
## copia automaticamente para eles cada jogador que o host adicionar.

const PLAYER_SCENE: PackedScene = preload("res://scenes/player.tscn")
## Onde cada jogador nasce (o 5º em diante volta ao primeiro ponto).
const SPAWN_POINTS: Array[Vector2] = [
	Vector2(0, 60), Vector2(-50, 60), Vector2(50, 60), Vector2(0, 100),
]

var _spawn_count: int = 0


func _ready() -> void:
	if not NetworkManager.start_pending():
		NetworkManager.leave_game(NetworkManager.menu_message)
		return

	# Só o host cria e remove jogadores.
	if multiplayer.is_server():
		multiplayer.peer_connected.connect(_spawn_player)
		multiplayer.peer_disconnected.connect(_remove_player)
		_spawn_player(1)  # o próprio host (ou o jogador solo) tem id 1


func _unhandled_input(event: InputEvent) -> void:
	# ESC sai da partida e volta ao menu.
	if event.is_action_pressed("ui_cancel"):
		NetworkManager.leave_game()


func _spawn_player(peer_id: int) -> void:
	var player: Node2D = PLAYER_SCENE.instantiate()
	# O nome do nó é o id do peer: o Player usa isso para saber quem é o dono.
	player.name = str(peer_id)
	player.position = SPAWN_POINTS[_spawn_count % SPAWN_POINTS.size()]
	_spawn_count += 1
	add_child(player)


func _remove_player(peer_id: int) -> void:
	var player: Node = get_node_or_null(str(peer_id))
	if player != null:
		player.queue_free()
