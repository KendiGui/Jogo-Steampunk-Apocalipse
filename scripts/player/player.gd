class_name Player
extends CharacterBody2D
## Personagem de teste da Fase 1: anda, mira e ataca corpo a corpo.
## Os controles vêm do nó PlayerInput. Os acertos só são aplicados pelo host
## (multiplayer.is_server()), conforme a regra de arquitetura do projeto.

@export var move_speed: float = 90.0
@export var attack_damage: int = 10
## Tempo mínimo entre um golpe e o próximo, em segundos.
@export var attack_cooldown: float = 0.45
## Metade do arco do golpe, em graus (70 = arco total de 140 graus).
@export var swing_half_angle_degrees: float = 70.0

var _cooldown_left: float = 0.0
var _is_attacking: bool = false

@onready var _input: PlayerInput = $PlayerInput
@onready var _body_sprite: Sprite2D = $BodySprite
@onready var _weapon_pivot: Node2D = $WeaponPivot
@onready var _weapon_sprite: Sprite2D = $WeaponPivot/WeaponSprite
@onready var _hitbox: Area2D = $Hitbox
@onready var _slash_effect: Sprite2D = $SlashEffect
@onready var _camera: Camera2D = $Camera2D


func _ready() -> void:
	# Só o jogador local usa a câmera (importante quando houver vários jogadores).
	_camera.enabled = is_multiplayer_authority()
	_hitbox.monitoring = false
	_slash_effect.visible = false


func _physics_process(delta: float) -> void:
	_cooldown_left = maxf(_cooldown_left - delta, 0.0)

	# Movimento
	velocity = _input.move_direction * move_speed
	move_and_slide()

	# Mira (a arma só segue o mouse quando não está no meio de um golpe)
	if not _is_attacking:
		_update_aim_visuals(_input.aim_direction)

	# Ataque
	if _input.attack_pressed and _cooldown_left <= 0.0 and not _is_attacking:
		_attack()


func _update_aim_visuals(aim: Vector2) -> void:
	_weapon_pivot.rotation = aim.angle()
	var aiming_left: bool = aim.x < 0.0
	# Vira o corpo e a espada para não ficarem de cabeça para baixo.
	_body_sprite.flip_h = aiming_left
	_weapon_sprite.flip_v = aiming_left


func _attack() -> void:
	_is_attacking = true
	_cooldown_left = attack_cooldown

	var base_angle: float = _input.aim_direction.angle()
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
