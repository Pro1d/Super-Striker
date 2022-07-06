extends Spatial

const OrbitalBody := preload("res://entities/OrbitalBody.gd")
const PhotonProjectile := preload("res://entities/PhotonProjectile.tscn")

onready var ship := $".."
onready var planet := OrbitalBody.get_planet(self)

func _on_Timer_timeout():
	var new_projectile = PhotonProjectile.instance()
	planet.add_child(new_projectile)
	new_projectile.init(global_transform, 10.0)
