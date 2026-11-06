class_name EnemyData
extends Resource
## Dados de um tipo de inimigo. Criar um inimigo novo = criar um .tres novo
## em resources/enemies/ e preencher estes campos (sem mexer em código).
## ATENÇÃO: os números atuais são valores de TESTE, não de balanceamento.

@export var id: StringName = &""
@export var display_name: String = ""
@export var max_health: int = 20
@export var move_speed: float = 40.0
@export var attack_damage: int = 5
## Distância (centro a centro) em que o inimigo consegue atacar o alvo.
@export var attack_range: float = 20.0
@export var attack_cooldown: float = 1.0
@export var collision_radius: float = 6.0
@export var texture: Texture2D
## "crystal" = vai sempre ao Cristal. "player" = prefere o jogador mais próximo.
@export_enum("crystal", "player") var target_priority: String = "crystal"
