@tool
extends EditorPlugin

# Autoloads que l'on veut ajouter
var autoloads = {
	"LobbyManager": "res://addons/Multiplayer/Lobby/LobbyManager.tscn",
	"MultiplayerManager": "res://addons/Multiplayer/MultiplayerManager.tscn",
	"Nakama": "res://addons/com.heroiclabs.nakama/Nakama.gd"
}

# Fonction appelée quand le plugin est activé
func _enter_tree():
	for name in autoloads.keys():
		# Ajouter directement l'autoload
		add_autoload_singleton(name, autoloads[name])
	ProjectSettings.save()

# Fonction appelée quand le plugin est désactivé
func _exit_tree():
	for name in autoloads.keys():
		# Supprimer directement l'autoload
		remove_autoload_singleton(name)
	ProjectSettings.save()
