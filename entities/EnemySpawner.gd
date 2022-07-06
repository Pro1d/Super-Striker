extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const Enemy = preload("res://entities/Enemy.tscn")
const RunnerEnemy = preload("res://entities/RunnerEnemy.tscn")
onready var planet_radius := OrbitalBody.get_planet_radius(self)

var enemies := []

# Called when the node enters the scene tree for the first time.
func _ready():
	var height := planet_radius + 2.0
	for _i in range(250):
		var random_position = Vector3(1, 1, 1)
		while random_position.length_squared() > 1:
			random_position = Vector3(
				randf() * 2 - 1,
				randf() * 2 - 1,
				randf() * 2 - 1)
		var e := RunnerEnemy.instance() as KinematicBody
		add_child(e)
		e.global_transform = Transform.IDENTITY
		e.global_transform.origin = OrbitalBody.projected_position(height, random_position)
		e.global_transform.basis = OrbitalBody.adjusted_orientation(e.global_transform)
		e.rotate_object_local(Vector3.UP, randf() * 2 * PI)
		enemies.append(e)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
