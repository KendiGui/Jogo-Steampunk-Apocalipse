class_name Player
extends CharacterBody2D
## Personagem de teste da Fase 1: anda, mira e ataca corpo a corpo, em rede.
##
## Modelo host-autoritativo:
## - Este nó (Player) pertence ao HOST (autoridade 1). Só o host move o corpo,
##   controla o cooldown e decide os acertos. A posição vai para os clientes
##   pelo nó StateSynchronizer.
## - O nó PlayerInput pertence ao DONO do jogador (o peer cujo id é o nome do nó).
##   Ele lê os controles e os envia ao host pelo nó InputSynchronizer.

@export var move_speed: float = 90.0
@export var attack_damage: int = 10
## Tempo mínimo entre um golpe e o próximo, em segundos.
@export var attack_cooldown: float = 0.45
## Metade do arco do golpe, em graus (70 = arco total de 140 graus).
@export var swing_half_angle_degrees: float = 70.0
## Vida máxima (valor de TESTE).
@export var max_health: int = 100

## Vida atual e estado de queda. São do host e replicados pelo StateSynchronizer.
var health: int = 100
var is_dead: bool = false:
	set(value):
		is_dead = value
		if is_node_ready():
			_apply_dead_visuals()

var _cooldown_left: float = 0.0
var _is_attacking: bool = false

@onready var _input: PlayerInput = $PlayerInput
@onready var _body_sprite: Sprite2D = $BodySprite
@onready var _weapon_pivot: Node2D = $WeaponPivot
@onready var _weapon_sprite: Sprite2D = $WeaponPivot/WeaponSprite
@onready var _hitbox: Area2D = $Hitbox
@onready var _slash_effect: Sprite2D = $SlashEffect
@onready var _camera: Camera2D = $Camera2D


func _enter_tree() -> void:
	# O nome do nó é o id do peer dono (a arena cria o nó com esse nome).
	# O PlayerInput (e o InputSynchronizer dentro dele) passa a ser do dono;
	# o resto do Player continua sendo do host.
	if name.is_valid_int():
		$PlayerInput.set_multiplayer_authority(name.to_int())


func _ready() -> void:
	# Só a pessoa que controla este jogador usa a câmera dele.
	_camera.enabled = _input.is_multiplayer_authority()
	_hitbox.monitoring = false
	_slash_effect.visible = false
	if multiplayer.is_server():
		health = max_health
	_apply_dead_visuals()


func _physics_process(delta: float) -> void:
	# Só o host move o corpo e decide quando o ataque começa.
	if multiplayer.is_server() and not is_dead:
		_cooldown_left = maxf(_cooldown_left - delta, 0.0)
		velocity = _input.move_direction * move_speed
		move_and_slide()
		if _input.attack_pressed and _cooldown_left <= 0.0 and not _is_attacking:
			_cooldown_left = attack_cooldown
			# Manda todo mundo (inclusive o host) mostrar o golpe.
			_play_attack.rpc(_input.aim_direction.angle())

	# Mira: todos os peers atualizam o visual (a mira chega pelo InputSynchronizer).
	if not _is_attacking:
		_update_aim_visuals(_input.aim_direction)


## Chamada pelos inimigos (no host).
func take_damage(amount: int, _from_position: Vector2) -> void:
	if not multiplayer.is_server() or is_dead:
		return
	health = maxi(health - amount, 0)
	_show_hit.rpc(amount)
	if health == 0:
		is_dead = true  # replicado aos clientes; sem reviver por enquanto (Fase 5)


@rpc("authority", "call_local", "reliable")
func _show_hit(amount: int) -> void:
	HitEffects.play(self, _body_sprite, amount, -34.0)


## Jogador caído fica meio transparente e sem arma.
func _apply_dead_visuals() -> void:
	_body_sprite.modulate = Color(1, 1, 1, 0.35) if is_dead else Color.WHITE
	_weapon_pivot.visible = not is_dead


func _update_aim_visuals(aim: Vector2) -> void:
	_weapon_pivot.rotation = aim.angle()
	var aiming_left: bool = aim.x < 0.0
	# Vira o corpo e a espada para não ficarem de cabeça para baixo.
	_body_sprite.flip_h = aiming_left
	_weapon_sprite.flip_v = aiming_left


## Chamado pelo host em todos os peers (call_local = também roda no host).
@rpc("authority", "call_local", "reliable")
func _play_attack(base_angle: float) -> void:
	_is_attacking = true
	var half_swing: float = deg_to_rad(swing_half_angle_degrees)

	# Posiciona a área de acerto e o efeito visual na direção da mira.
	_hitbox.rotation = base_angle
	_slash_effect.rotation = base_angle
	_slash_effect.modulate.a = 1.0
	_slash_effect.visible = true
	_hitbox.monitoring = true

	# A espada gira de um lado ao outro do arco.
	_weapon_pivot.rotation = base_angle - half_swing
	var swing_tween: Tween = create_tween()
	swing_tween.tween_property(_weapon_pivot, "rotation", base_angle + half_swing, 0.12)

	# Espera a área de acerto detectar quem está dentro (precisa de um tempinho).
	await get_tree().create_timer(0.08).timeout
	_apply_hits()
	_hitbox.monitoring = false

	# Some com o efeito e libera o próximo golpe.
	var fade_tween: Tween = create_tween()
	fade_tween.tween_property(_slash_effect, "modulate:a", 0.0, 0.1)
	await fade_tween.finished
	_slash_effect.visible = false
	_is_attacking = false


func _apply_hits() -> void:
	# Só o host decide o dano. Em jogo solo, o próprio jogador é o host.
	if not multiplayer.is_server():
		return
	for body: Node2D in _hitbox.get_overlapping_bodies():
		if body != self and body.has_method("take_damage"):
			body.take_damage(attack_damage, global_position)
