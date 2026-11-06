class_name Crystal
extends StaticBody2D
## Cristal de Energia: se a vida chegar a zero, a run acaba.
## A vida pertence ao host e é copiada aos clientes pelo MultiplayerSynchronizer.
## ATENÇÃO: o valor da vida é de TESTE.

signal destroyed

@export var max_health: int = 500

## Vida atual (replicada pela rede). Começa cheia.
var health: int = 500

@onready var _sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	if multiplayer.is_server():
		health = max_health


func _process(_delta: float) -> void:
	# Quanto menos vida, mais avermelhado fica o Cristal.
	var damage_ratio: float = 1.0 - float(health) / float(max_health)
	_sprite.modulate = Color.WHITE.lerp(Color(1.0, 0.45, 0.45), damage_ratio)


## Chamada pelos inimigos (no host).
func take_damage(amount: int, _from_position: Vector2) -> void:
	if not multiplayer.is_server() or health <= 0:
		return
	health = maxi(health - amount, 0)
	_show_hit.rpc(amount)
	if health == 0:
		destroyed.emit()


@rpc("authority", "call_local", "reliable")
func _show_hit(amount: int) -> void:
	HitEffects.play(self, _sprite, amount, -50.0)
