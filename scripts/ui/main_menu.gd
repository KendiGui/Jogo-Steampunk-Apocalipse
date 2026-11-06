extends Control
## Menu inicial: Solo, Criar partida (host) ou Entrar (join).

@onready var _solo_button: Button = $Center/VBox/SoloButton
@onready var _host_button: Button = $Center/VBox/HostButton
@onready var _ip_field: LineEdit = $Center/VBox/IpField
@onready var _join_button: Button = $Center/VBox/JoinButton
@onready var _status_label: Label = $Center/VBox/StatusLabel


func _ready() -> void:
	_solo_button.pressed.connect(_on_solo_pressed)
	_host_button.pressed.connect(_on_host_pressed)
	_join_button.pressed.connect(_on_join_pressed)
	# Mostra o motivo de termos voltado ao menu (conexão caiu, etc.).
	_status_label.text = NetworkManager.menu_message


func _on_solo_pressed() -> void:
	NetworkManager.begin_game(NetworkManager.Mode.SOLO)


func _on_host_pressed() -> void:
	NetworkManager.begin_game(NetworkManager.Mode.HOST)


func _on_join_pressed() -> void:
	var address: String = _ip_field.text.strip_edges()
	if address.is_empty():
		_status_label.text = "Digite o IP do host."
		return
	NetworkManager.begin_game(NetworkManager.Mode.JOIN, address)
