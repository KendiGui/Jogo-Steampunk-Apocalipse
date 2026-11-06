class_name PlayerInput
extends Node
## Lê os controles e guarda o resultado em variáveis simples.
## O jogador (player.gd) só olha essas variáveis; nunca lê teclas ou botões.
## Na Fase 1 (rede), só o dono do jogador roda a leitura; os valores serão
## enviados ao host. Por isso a leitura vive neste nó separado.

## Direção de movimento (já limitada a tamanho 1).
var move_direction: Vector2 = Vector2.ZERO
## Direção da mira (sempre tamanho 1).
var aim_direction: Vector2 = Vector2.RIGHT
## True enquanto o botão de ataque estiver apertado.
var attack_pressed: bool = false

## Altura do "peito" do personagem: de onde sai a mira.
@export var aim_origin_offset: Vector2 = Vector2(0, -10)
## Quanto o analógico direito precisa ser movido para valer como mira.
@export var stick_aim_threshold: float = 0.3

@onready var _player: Node2D = get_parent() as Node2D


func _physics_process(_delta: float) -> void:
	# Só quem controla este jogador lê os controles.
	if not is_multiplayer_authority():
		return

	move_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	attack_pressed = Input.is_action_pressed("attack")
	aim_direction = _read_aim()


func _read_aim() -> Vector2:
	# 1) Controle: se o analógico direito está sendo usado, ele manda.
	var stick: Vector2 = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
	if stick.length() > stick_aim_threshold:
		return stick.normalized()

	# 2) Mouse: direção do personagem até o cursor.
	var origin: Vector2 = _player.global_position + aim_origin_offset
	var to_mouse: Vector2 = _player.get_global_mouse_position() - origin
	if to_mouse.length() > 1.0:
		return to_mouse.normalized()

	# Cursor em cima do personagem: mantém a última mira.
	return aim_direction
