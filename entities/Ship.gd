extends KinematicBody

signal health_changed(health, max_health)

const OrbitalBody := preload("res://entities/OrbitalBody.gd")
const PhotonProjectile := preload("res://entities/PhotonProjectile.tscn")

export var max_linear_speed := 4.0
export var max_linear_accel := 100.0
export var max_steering_speed := 1.0
export var max_steering_accel := 8.0
export var height := 2.0
export var invunerability_frame_duration := 1.0
export var max_health := 5

var steering_command := 0.0
var steering_speed := 0.0
var linear_command := 1.0
var linear_speed := 0.0
var invunerability_frame_active := false
var health := max_health

onready var planet_radius := OrbitalBody.get_planet_radius(self)

# Called when the node enters the scene tree for the first time.
func _ready():
	global_transform.origin = OrbitalBody.projected_position(
		planet_radius + height,
		global_transform.origin)
	global_transform.basis = OrbitalBody.adjusted_orientation(
		global_transform)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta : float):
	var left := Input.get_action_strength("steering_left")
	var right := Input.get_action_strength("steering_right")
	var boost := Input.get_action_strength("boost")
	steering_command = left - right
	linear_command = 1.0 + boost
	
	steering_speed = move_toward(
		steering_speed,
		steering_command * max_steering_speed,
		max_steering_accel * delta)
	linear_speed = move_toward(
		linear_speed,
		linear_command * max_linear_speed,
		max_linear_accel * delta)
	
	$Visual.rotation.z = PI / 6 * steering_speed / max_steering_speed

func _physics_process(delta : float):
	var h := height + planet_radius
	# translate
	var rel_global_translate := OrbitalBody.to_global_translate(
		Vector2(linear_speed * delta, 0), h, global_transform)
	move_and_slide(rel_global_translate / delta)
	
	# adjust transform
	global_transform.origin = OrbitalBody.projected_position(
		h,
		global_transform.origin)
	global_transform.basis = OrbitalBody.adjusted_orientation(global_transform)

	# rotate
	var heading_speed := steering_speed
	rotate_object_local(Vector3.UP, heading_speed * delta)

func _end_invunerability_frame():
	invunerability_frame_active = false

func _trigger_invunerability_frame():
	invunerability_frame_active = true
	get_tree().create_timer(1.0).connect("timeout", self, "_end_invunerability_frame")

func take_damage(damage : int):
	health = max(health - damage, 0)
	emit_signal("health_changed", health, max_health)
	if health == 0:
		pass # dead
	else:
		_trigger_invunerability_frame()

func on_enemy_collided(body):
	if not invunerability_frame_active:
		take_damage(1)

func _on_contact_area_body_entered(body):
	on_enemy_collided(body)
