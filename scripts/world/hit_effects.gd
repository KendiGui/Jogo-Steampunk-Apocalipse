class_name HitEffects
extends RefCounted
## Efeitos visuais de "tomou dano" usados por inimigos, jogadores e Cristal:
## pisca em branco e mostra o número do dano flutuando.


static func play(host: Node2D, sprite: Sprite2D, amount: int, label_y: float) -> void:
	# Pisca em branco (self_modulate, para não brigar com outras cores do sprite).
	sprite.self_modulate = Color(2.5, 2.5, 2.5)
	var flash: Tween = sprite.create_tween()
	flash.tween_property(sprite, "self_modulate", Color.WHITE, 0.15)

	# Número de dano flutuando.
	var label: Label = Label.new()
	label.text = str(amount)
	label.add_theme_font_size_override("font_size", 8)
	label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.4))
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 3)
	label.position = Vector2(-4, label_y)
	host.add_child(label)
	var float_up: Tween = label.create_tween()
	float_up.set_parallel(true)
	float_up.tween_property(label, "position:y", label_y - 16.0, 0.5)
	float_up.tween_property(label, "modulate:a", 0.0, 0.5)
	float_up.chain().tween_callback(label.queue_free)
