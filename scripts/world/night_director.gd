class_name NightDirector
extends Node
## Controla a partida: espera o botão, faz a noite (ondas de inimigos) e
## decide a derrota. Toda a lógica roda só no host. Os clientes recebem
## state, night, enemies_left e game_over_reason pelo MultiplayerSynchronizer.
##
## ATENÇÃO: todos os números abaixo são valores de TESTE.

enum State { PREP, NIGHT, GAME_OVER }

const ENEMY_SCENE: PackedScene = preload("res://scenes/enemy.tscn")
## Limite de inimigos vivos ao mesmo tempo (custo de rede, risco 6 do GDD).
const MAX_ALIVE: int = 12
## Segundos entre um nascimento e outro.
const SPAWN_INTERVAL: float = 1.0
## Distância da borda da arena onde os inimigos nascem.
const SPAWN_MARGIN: float = 24.0
const ARENA_HALF_SIZE: Vector2 = Vector2(480, 272)

## Valores replicados (host escreve, todos leem).
var state: int = State.PREP
## Número da noite atual (ou da próxima, enquanto está em PREP).
var night: int = 1
## Inimigos que ainda faltam nascer + vivos.
var enemies_left: int = 0
var game_over_reason: String = ""

var _queue: Array[String] = []
var _spawn_timer: float = 0.0
var _next_enemy_id: int = 0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()
	if multiplayer.is_server():
		var crystal: Crystal = get_tree().get_first_node_in_group("crystal") as Crystal
		crystal.destroyed.connect(_on_crystal_destroyed)


## Qualquer jogador pode pedir o início da noite; só o host executa.
@rpc("any_peer", "call_local", "reliable")
func request_start_night() -> void:
	if not multiplayer.is_server() or state != State.PREP:
		return
	_start_night()


func _physics_process(delta: float) -> void:
	if not multiplayer.is_server() or state == State.GAME_OVER:
		return

	_check_all_players_down()

	if state != State.NIGHT:
		return

	var alive: int = get_tree().get_nodes_in_group("enemies").size()
	enemies_left = alive + _queue.size()

	# Nasce o próximo inimigo da fila, respeitando intervalo e limite.
	_spawn_timer -= delta
	if not _queue.is_empty() and alive < MAX_ALIVE and _spawn_timer <= 0.0:
		_spawn_timer = SPAWN_INTERVAL
		_spawn_enemy(_queue.pop_back())

	# Noite vencida: fila vazia e nenhum inimigo vivo.
	if _queue.is_empty() and alive == 0:
		night += 1
		state = State.PREP


func _start_night() -> void:
	# Composição de teste: mais inimigos a cada noite.
	_queue.clear()
	for i: int in range(night):
		_queue.append("brute")
	for i: int in range(2 + 2 * night):
		_queue.append("agile")
	_shuffle_queue()
	enemies_left = _queue.size()
	_spawn_timer = 0.0
	state = State.NIGHT


func _shuffle_queue() -> void:
	for i: int in range(_queue.size() - 1, 0, -1):
		var j: int = _rng.randi_range(0, i)
		var tmp: String = _queue[i]
		_queue[i] = _queue[j]
		_queue[j] = tmp


func _spawn_enemy(enemy_type: String) -> void:
	var enemy: Enemy = ENEMY_SCENE.instantiate() as Enemy
	enemy.enemy_type = enemy_type
	enemy.name = "Enemy_%d" % _next_enemy_id
	_next_enemy_id += 1
	enemy.position = _random_edge_point()
	# Filho da arena: o MultiplayerSpawner copia o inimigo para os clientes.
	get_parent().add_child(enemy)


func _random_edge_point() -> Vector2:
	var half: Vector2 = ARENA_HALF_SIZE - Vector2(SPAWN_MARGIN, SPAWN_MARGIN)
	var along_x: float = _rng.randf_range(-half.x, half.x)
	var along_y: float = _rng.randf_range(-half.y, half.y)
	match _rng.randi_range(0, 3):
		0: return Vector2(along_x, -half.y)
		1: return Vector2(along_x, half.y)
		2: return Vector2(-half.x, along_y)
		_: return Vector2(half.x, along_y)


func _check_all_players_down() -> void:
	var players: Array[Node] = get_tree().get_nodes_in_group("players")
	if players.is_empty():
		return
	for node: Node in players:
		if not (node as Player).is_dead:
			return
	_game_over("Todos os jogadores caíram.")


func _on_crystal_destroyed() -> void:
	_game_over("O Cristal de Energia foi destruído.")


func _game_over(reason: String) -> void:
	if state == State.GAME_OVER:
		return
	game_over_reason = reason
	state = State.GAME_OVER
	_queue.clear()
	for enemy: Node in get_tree().get_nodes_in_group("enemies"):
		enemy.queue_free()
