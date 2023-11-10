extends Control

@onready var server_list_container: VBoxContainer = $ServerListContainer


signal server_button_pressed(server_ip : String)


func _ready() -> void:
	ServiceDiscovery.scanned_server.connect(_on_scanned_server)


func add_server_button(server_data : Dictionary) -> void:
	var new_button := Button.new()
	
	new_button.text = "%s (%s)" % [server_data.server_data.Name, server_data.server_ip]
	new_button.size_flags_horizontal = Control.SIZE_EXPAND
	new_button.pressed.connect(_on_server_button_pressed.bind(server_data.server_ip))
	
	server_list_container.add_child(new_button)


func _on_scanned_server(server_data : Dictionary) -> void:
	add_server_button(server_data)


func _on_timer_timeout() -> void:
	for c in server_list_container.get_children():
		c.queue_free()
	
	ServiceDiscovery.scan_lan_servers()


func _on_server_button_pressed(server_ip) -> void:
	server_button_pressed.emit(str(server_ip))
