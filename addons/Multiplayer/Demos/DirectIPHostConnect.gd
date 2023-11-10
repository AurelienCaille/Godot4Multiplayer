extends Panel


@onready var ip_line_edit: LineEdit = $HBoxContainer/IPLineEdit
@onready var name_server_line_edit: LineEdit = %NameServerLineEdit


signal ip_connection_requested(ip : String)
signal host_requested


func _on_join_button_pressed() -> void:
	var ip : String = ip_line_edit.text
	
	if not ip.is_valid_ip_address():
		push_warning("IP address it not valid: %s" % [ip])
		return
	
	ip_connection_requested.emit(ip)


func _on_host_button_pressed() -> void:
	ServiceDiscovery.server_data['Name'] = name_server_line_edit.text
	ServiceDiscovery.set_server()
	host_requested.emit()


func _on_matches_lan_list_ui_server_button_pressed(server_ip) -> void:
	ip_connection_requested.emit(server_ip)
