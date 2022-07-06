class_name Projectile
extends Area

const OrbitalBody := preload("res://entities/OrbitalBody.gd")

export var velocity := 10.0
export var life_time := 2.5
export var damage := 1.0
export var knockback_strength := 0.6

var height : float
var can_hit := true
var alive := false

func init(start_pose : Transform, _velocity : float):
	global_transform = start_pose
	height = start_pose.origin.length()
	velocity = _velocity
	global_transform.basis = OrbitalBody.adjusted_orientation(
		global_transform)

func _ready():
	connect("body_entered", self, "_collided")
	get_tree().create_timer(life_time).connect("timeout", self, "_destroy")

func _destroy():
	# animation	Tween + yield(tween, "tween_all_completed")
	can_hit = false
	queue_free()

func _physics_process(delta : float):
	var step := velocity * delta
	var translate := OrbitalBody.to_global_translate(
		Vector2(step, 0.0),
		height,
		global_transform)
	global_translate(translate)
	
	var orientation := OrbitalBody.adjusted_orientation(global_transform)
	global_transform.basis = orientation

func _collided(body):
	if can_hit:
		if body.has_method("on_projectile_hit"):
			var knockback_dir := global_transform.basis * Vector3.FORWARD
			var knockback_force := knockback_dir * velocity
			body.on_projectile_hit(knockback_force, knockback_strength, damage)
		$Impact.restart()
		$MeshInstance.hide()
		get_tree().create_timer($Impact.lifetime).connect("timeout", self, "_destroy")
		can_hit = false
		alive = false
