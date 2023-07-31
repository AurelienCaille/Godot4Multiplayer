extends Panel


@onready var ip_line_edit: LineEdit = $HBoxContainer/IPLineEdit

signal ip_connection_requested(ip : String)
signal host_requested


func _on_join_button_pressed() -> void:
	var ip : String = ip_line_edit.text
	
	if not ip.is_valid_ip_address():
		push_warning("IP address it not valid: %s" % [ip])
		return
	
	ip_connection_requested.emit(ip)


func _on_host_button_pressed() -> void:
	host_requested.emit()
