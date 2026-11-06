class_name Enemy
extends CharacterBody2D
## Inimigo genérico. O tipo (brute, agile...) vem de um Resource EnemyData.
## Toda a IA e o dano rodam só no host; os clientes só recebem posição e efeitos.

## Nome do arquivo em resources/enemies/ (sem o .tres). Replicado no spawn.
var enemy_type: String = "agile"

var data: EnemyData
var health: int = 0

var _cooldown_left: float = 0.0
var _is_dying: bool = false
var _last_x: float = 0.0

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _collision: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	data = load("res://resources/enemies/%s.tres" % enemy_type) as EnemyData
	health = data.max_health

	# Cada inimigo tem o próprio formato de colisão (não compartilhado).
	var shape: CircleShape2D = CircleShape2D.new()
	shape.radius = data.collision_radius
	_collision.shape = shape

	# Pés do sprite no ponto de origem do nó.
	_sprite.texture = data.texture
	_sprite.offset = Vector2(0, -data.texture.get_height() / 2.0)
	_last_x = position.x


func _physics_process(delta: float) -> void:
	# Visual (todos os peers): vira o sprite para onde está andando.
	var moved_x: float = position.x - _last_x
	if absf(moved_x) > 0.05:
		_sprite.flip_h = moved_x < 0.0
	_last_x = position.x

	# IA (só host).
	if not multiplayer.is_server() or _is_dying:
		return
	_cooldown_left = maxf(_cooldown_left - delta, 0.0)

	var target: Node2D = _find_target()
	if target == null:
		velocity = Vector2.ZERO
		return

	var to_target: Vector2 = target.global_position - global_position
	if to_target.length() > data.attack_range:
		velocity = to_target.normalized() * data.move_speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO
		if _cooldown_left <= 0.0:
			_cooldown_left = data.attack_cooldown
			target.take_damage(data.attack_damage, global_position)
			_play_attack.rpc()


## Escolhe o alvo conforme o tipo de inimigo (só o host chama).
func _find_target() -> Node2D:
	var crystal: Node2D = get_tree().get_first_node_in_group("crystal") as Node2D
	if data.target_priority == "player":
		var nearest: Node2D = _nearest_living_player()
		if nearest != null:
			return nearest
	return crystal


func _nearest_living_player() -> Node2D:
	var best: Node2D = null
	var best_distance: float = INF
	for node: Node in get_tree().get_nodes_in_group("players"):
		var player: Player = node as Player
		if player == null or player.is_dead:
			continue
		var distance: float = global_position.distance_squared_to(player.global_position)
		if distance < best_distance:
			best_distance = distance
			best = player
	return best


## Chamado pelo golpe do jogador (no host).
func take_damage(amount: int, _from_position: Vector2) -> void:
	if not multiplayer.is_server() or _is_dying:
		return
	health -= amount
	var dying: bool = health <= 0
	if dying:
		_is_dying = true
		remove_from_group("enemies")  # o diretor da noite deixa de contar este inimigo
		_collision.set_deferred("disabled", true)
	_show_hit.rpc(amount, dying)
	if dying:
		await get_tree().create_timer(0.3).timeout
		queue_free()  # o MultiplayerSpawner remove nos clientes também


@rpc("authority", "call_local", "reliable")
func _show_hit(amount: int, dying: bool) -> void:
	HitEffects.play(self, _sprite, amount, -_sprite.texture.get_height() - 4.0)
	if dying:
		var fade: Tween = create_tween()
		fade.tween_property(_sprite, "modulate:a", 0.0, 0.25)


@rpc("authority", "call_local", "reliable")
func _play_attack() -> void:
	# Dá uma "apertadinha" no sprite para mostrar que atacou.
	var squash: Tween = create_tween()
	squash.tween_property(_sprite, "scale", Vector2(1.3, 0.8), 0.06)
	squash.tween_property(_sprite, "scale", Vector2.ONE, 0.1)
