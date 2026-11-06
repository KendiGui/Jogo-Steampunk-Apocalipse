extends CanvasLayer
## HUD: vida do Cristal, vida do jogador local, estado da noite e botões.
## Só lê valores (que já chegam por rede); o único comando é o botão da noite.

@onready var _director: NightDirector = get_node("../Director")
@onready var _crystal: Crystal = get_node("../Crystal")

@onready var _crystal_bar: ProgressBar = $TopLeft/CrystalBar
@onready var _player_bar: ProgressBar = $TopLeft/PlayerBar
@onready var _night_label: Label = $NightLabel
@onready var _start_button: Button = $StartNightButton
@onready var _game_over_panel: Control = $GameOverPanel
@onready var _reason_label: Label = $GameOverPanel/Center/VBox/ReasonLabel
@onready var _menu_button: Button = $GameOverPanel/Center/VBox/MenuButton


func _ready() -> void:
	_start_button.pressed.connect(_on_start_pressed)
	_menu_button.pressed.connect(_on_menu_pressed)
	_crystal_bar.max_value = _crystal.max_health


func _process(_delta: float) -> void:
	_crystal_bar.value = _crystal.health

	var local_player: Player = _find_local_player()
	if local_player != null:
		_player_bar.max_value = local_player.max_health
		_player_bar.value = local_player.health

	match _director.state:
		NightDirector.State.PREP:
			_night_label.text = "Prepare-se para a noite %d" % _director.night
		NightDirector.State.NIGHT:
			_night_label.text = "Noite %d  -  inimigos: %d" % [_director.night, _director.enemies_left]
		NightDirector.State.GAME_OVER:
			_night_label.text = ""

	_start_button.visible = _director.state == NightDirector.State.PREP
	_start_button.text = "Começar noite %d" % _director.night
	_game_over_panel.visible = _director.state == NightDirector.State.GAME_OVER
	_reason_label.text = _director.game_over_reason


## O jogador controlado por este computador (o PlayerInput pertence a ele).
func _find_local_player() -> Player:
	for node: Node in get_tree().get_nodes_in_group("players"):
		var player: Player = node as Player
		if player != null and player.get_node("PlayerInput").is_multiplayer_authority():
			return player
	return null


func _on_start_pressed() -> void:
	# Pede ao host (id 1) para começar a noite.
	_director.request_start_night.rpc_id(1)


func _on_menu_pressed() -> void:
	NetworkManager.leave_game()
