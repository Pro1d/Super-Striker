extends Node


var environment : int setget , _environment
var player : int setget , _player
var enemy : int setget , _enemy
var player_projectile : int setget , _player_projectile
var enemy_projectile : int setget , _enemy_projectile

func _init():
	var _name_to_bit = {}
	for i in range(32):
		var param_name := str("layer_names/3d_physics/layer_", i + 1)
		if ProjectSettings.has_setting(param_name):
			var layer_name = ProjectSettings.get_setting(param_name)
			_name_to_bit[layer_name] = (1 << i)
	
	environment = _name_to_bit["environment"]
	player = _name_to_bit["player"]
	enemy = _name_to_bit["enemy"]
	player_projectile = _name_to_bit["player_projectile"]
	enemy_projectile = _name_to_bit["enemy_projectile"]

func _environment() -> int:
	return environment

func _player() -> int:
	return player

func _enemy() -> int:
	return enemy

func _player_projectile() -> int:
	return player_projectile

func _enemy_projectile() -> int:
	return enemy_projectile
