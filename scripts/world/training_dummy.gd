extends StaticBody2D
## Boneco de treino: não morre, só reage aos golpes para a gente enxergar o ataque.

@onready var _sprite: Sprite2D = $Sprite2D


## Chamada pelo jogador (no host) quando o golpe acerta.
func take_damage(amount: int, from_position: Vector2) -> void:
	# Roda só no host (quem chama é o golpe do jogador, que o host valida).
	# O efeito visual é enviado a todos os jogadores.
	_show_hit.rpc(amount, from_position)


@rpc("authority", "call_local", "reliable")
func _show_hit(amount: int, from_position: Vector2) -> void:
	# Balança para o lado oposto a quem bateu.
	var push_side: float = signf(global_position.x - from_position.x)
	if push_side == 0.0:
		push_side = 1.0
	var wobble: Tween = create_tween()
	wobble.tween_property(_sprite, "rotation", 0.25 * push_side, 0.05)
	wobble.tween_property(_sprite, "rotation", 0.0, 0.2).set_trans(Tween.TRANS_ELASTIC)

	# Pisca em branco.
	_sprite.modulate = Color(2.5, 2.5, 2.5)
	var flash: Tween = create_tween()
	flash.tween_property(_sprite, "modulate", Color.WHITE, 0.15)

	# Número de dano flutuando.
	var label: Label = Label.new()
	label.text = str(amount)
	label.add_theme_font_size_override("font_size", 8)
	label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.4))
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 3)
	label.position = Vector2(-4, -36)
	add_child(label)
	var float_up: Tween = create_tween()
	float_up.set_parallel(true)
	float_up.tween_property(label, "position:y", -52.0, 0.5)
	float_up.tween_property(label, "modulate:a", 0.0, 0.5)
	float_up.chain().tween_callback(label.queue_free)
