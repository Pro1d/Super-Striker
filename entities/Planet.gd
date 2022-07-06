class_name Planet
extends StaticBody

export var radius := 50.0 setget _set_radius
export var cloud_height := 2.0
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	_update_radius()

func _update_radius():
	var ground_mesh := $GroundMesh.mesh as SphereMesh
	ground_mesh.radius = radius
	ground_mesh.height = radius * 2.0
	var cloud_mesh := $CloudMesh.mesh as SphereMesh
	cloud_mesh.radius = radius + cloud_height
	cloud_mesh.height = (radius + cloud_height) * 2.0
	var collision_shape := $CollisionShape.shape  as SphereShape
	collision_shape.radius = radius

func _set_radius(r):
	radius = r
	_update_radius()

