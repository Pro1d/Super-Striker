class_name Enemy
extends KinematicBody

export var max_life := 6.0
export var knockback_resistance := 0.0
export var linear_drag := 0.9505 # reduce speed by x% after 1 sec
export var max_linear_speed := 2.0
export var max_linear_accel := 100.0
export var max_steering_speed := 1.0
export var max_steering_accel := 8.0
export var height := 2.0

var alive := true
var linear_velocity := Vector2.ZERO
var angular_velocity := 0.0
var _has_goal := false
var _goal : Vector3

onready var life := max_life
onready var planet_radius := OrbitalBody.get_planet_radius(self)

# Called when the node enters the scene tree for the first time.
func _ready():
	global_transform.origin = OrbitalBody.projected_position(
		planet_radius + height,
		global_transform.origin)
	global_transform.basis = OrbitalBody.adjusted_orientation(
		global_transform)

func _physics_process(delta : float):
	linear_velocity *= pow(1 - linear_drag, delta)

	if _has_goal:
		var direction := OrbitalBody.local_direction_to(_goal, global_transform)
		var angle_direction := atan2(direction.y, direction.x)
		if abs(angle_direction) < angular_velocity * delta:
			angle_direction = 0.0
		var steering_command := sign(angle_direction)
		angular_velocity = move_toward(
			angular_velocity,
			steering_command * max_steering_speed,
			max_steering_accel * delta)
		var linear_command := max(0.0, direction.x)
		linear_velocity.x = move_toward(
			linear_velocity.x,
			linear_command * max_linear_speed,
			max_linear_accel * delta)
	else:
		angular_velocity = move_toward(
			angular_velocity,
			0.0,
			max_steering_accel * delta)

	var translate := OrbitalBody.to_global_translate(
		linear_velocity * delta,
		planet_radius + height,
		global_transform)
	move_and_slide(translate / delta)
	global_transform.origin = OrbitalBody.projected_position(
		planet_radius + height,
		global_transform.origin)
	global_transform.basis = OrbitalBody.adjusted_orientation(
		global_transform)
	rotate_object_local(Vector3.UP, angular_velocity * delta)

func _destroy():
	alive = false
	queue_free()

func _take_damage(damage : float):
	life -= damage
	if life < 0.001:
		_destroy()

func on_projectile_hit(knockback_force : Vector3, knockback_strength : float, damage : float):
	var local_knockback_force := global_transform.basis.inverse() * knockback_force
	var local_knockback_force_2d := OrbitalBody.local_3d_to_2d(local_knockback_force)
	var knockback_intensity := knockback_strength * (1.0 - knockback_resistance)
	linear_velocity += local_knockback_force_2d * knockback_intensity
	_take_damage(damage)

func move_to(goal : Vector3):
	_has_goal = true
	_goal = goal

func stop():
	_has_goal = false
