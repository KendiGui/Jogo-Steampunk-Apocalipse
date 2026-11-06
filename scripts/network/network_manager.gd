extends Node
## Autoload (existe o jogo inteiro). Cuida de criar o host, entrar numa partida
## e voltar ao menu quando a conexão cai.
##
## Fluxo: o menu escolhe o modo e troca para a arena. A ARENA então chama
## start_pending(). Assim, quando a conexão acontece, a arena já existe nas
## duas pontas e os jogadores podem ser criados sem erro.

const DEFAULT_PORT: int = 24565
## 4 jogadores no total (o host mais 3 clientes).
const MAX_PLAYERS: int = 4
const MENU_SCENE: String = "res://scenes/main_menu.tscn"
const ARENA_SCENE: String = "res://scenes/test_arena.tscn"

enum Mode { SOLO, HOST, JOIN }

var pending_mode: Mode = Mode.SOLO
var pending_address: String = "127.0.0.1"
## Mensagem para o menu mostrar (ex.: "Falha ao conectar").
var menu_message: String = ""


func _ready() -> void:
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


## Chamado pelo menu: guarda o que o jogador escolheu e abre a arena.
func begin_game(mode: Mode, address: String = "127.0.0.1") -> void:
	pending_mode = mode
	pending_address = address
	menu_message = ""
	get_tree().change_scene_to_file(ARENA_SCENE)


## Chamado pela arena assim que ela carrega. Retorna false se deu erro.
func start_pending() -> bool:
	match pending_mode:
		Mode.HOST:
			var host_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
			var host_error: Error = host_peer.create_server(DEFAULT_PORT, MAX_PLAYERS - 1)
			if host_error != OK:
				menu_message = "Não foi possível criar a partida (porta %d em uso?)." % DEFAULT_PORT
				return false
			multiplayer.multiplayer_peer = host_peer
		Mode.JOIN:
			var client_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
			var client_error: Error = client_peer.create_client(pending_address, DEFAULT_PORT)
			if client_error != OK:
				menu_message = "Endereço inválido: %s" % pending_address
				return false
			multiplayer.multiplayer_peer = client_peer
		Mode.SOLO:
			# Sem rede: o Godot usa um peer "offline" onde você é o host (id 1).
			multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	return true


## Sai da partida e volta ao menu (usado pelo ESC e quando a conexão cai).
func leave_game(message: String = "") -> void:
	menu_message = message
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	# "deferred" evita trocar de cena no meio de um sinal de rede.
	get_tree().call_deferred("change_scene_to_file", MENU_SCENE)


func _on_connection_failed() -> void:
	leave_game("Não foi possível conectar ao host.")


func _on_server_disconnected() -> void:
	leave_game("O host encerrou a partida.")
