extends "res://entities/Enemy.gd"

export var find_target_cooldown_duration := 0.5
export var search_distance := 10.0
export var follow_distance := 12.0

var find_target_ready := true
var has_goal := false
var target_ref := weakref(null)
var last_target_position : Vector3
var search_shape := SphereShape.new()
var space_search : PhysicsDirectSpaceState

onready var reach_distance := ($CollisionShape.shape as SphereShape).radius

func _ready():
	search_shape.radius = search_distance
	_trigger_find_target_cooldown()
	
func _process(delta : float):
	space_search = get_world().direct_space_state
	var self_pos := global_transform.origin
	if not _is_target_ref_valid():
		if find_target_ready:
			_find_target()
			_trigger_find_target_cooldown()

	if _is_target_ref_valid():
		var t := target_ref.get_ref() as Spatial
		var target_position := t.global_transform.origin
		if _is_target_in_follow_range() and \
				_is_visible(target_position, _target_distance(target_position)):
			last_target_position = t.global_transform.origin
			has_goal = true
		else:
			target_ref = weakref(null)

	if has_goal and _target_distance(last_target_position) > reach_distance:
		move_to(last_target_position)
	else:
		has_goal = false
		stop()

func _trigger_find_target_cooldown() -> void:
	find_target_ready = false
	get_tree().create_timer(find_target_cooldown_duration * (1 + randf())).connect(
		"timeout", self, "_reset_find_target_cooldown")

func _reset_find_target_cooldown() -> void:
	find_target_ready = true

func _is_target_ref_valid() -> bool:
	var t := target_ref.get_ref() as Spatial
	if t != null and t.is_inside_tree():
		return true
	else:
		target_ref = weakref(null)
		return false

func _is_target_in_follow_range() -> bool:
	var t := target_ref.get_ref() as Spatial
	return _target_distance(t.global_transform.origin) < follow_distance

func _find_target() -> void:
	var space_search_params := PhysicsShapeQueryParameters.new()
	space_search_params.set_shape(search_shape)
	space_search_params.collision_mask = Layer.player
	space_search_params.transform = global_transform
	var targets := space_search.intersect_shape(space_search_params)
	var dist_min := search_distance
	target_ref = weakref(null)
	for t in targets:
		var target_position = t["collider"].global_transform.origin
		var target_dist := _target_distance(target_position)
		if _is_visible(target_position, target_dist):
			if target_dist < dist_min:
				dist_min = target_dist
				target_ref = weakref(t["collider"])
				prints(t, _is_target_ref_valid(), _is_target_in_follow_range())

func _is_visible(target_position : Vector3, target_dist : float) -> bool:
	var result := space_search.intersect_ray(
		global_transform.origin,
		target_position,
		[],
		Layer.environment)
	return len(result) == 0 or \
		_target_distance(result["position"]) > target_dist

func _target_distance(target_position : Vector3) -> float:
	return global_transform.origin.distance_to(target_position)
