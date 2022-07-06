class_name OrbitalBody
extends Object

static func get_planet(node : Node) -> Planet:
	var space := node.get_node("/root/Space/Planet") as Planet
	return space

static func get_planet_radius(node : Node) -> float:
	return get_planet(node).radius

static func projected_position(
		height : float,
		position_global : Vector3) -> Vector3:

	return position_global.normalized() * height

static func local_2d_to_3d(p : Vector2) -> Vector3:
	return Vector3.FORWARD * p.x + Vector3.LEFT * p.y

static func local_3d_to_2d(p : Vector3) -> Vector2:
	return Vector2(-p.z, -p.x)

static func local_direction_to(
		position : Vector3,
		global_tf : Transform) -> Vector2:

	var global_direction := global_tf.origin.direction_to(position).normalized()
	# Project global direction on local Forward^Left plane.
	return Vector2(
		global_direction.dot(global_tf.basis * Vector3.FORWARD),
		global_direction.dot(global_tf.basis * Vector3.LEFT))
		

static func to_local_translate(
		global_translate : Vector3,
		global_tf : Transform) -> Vector2:

	var local := global_tf.basis.inverse() * global_translate
	return local_3d_to_2d(local)

static func to_global_translate(
		local_translate : Vector2,
		height : float,
		global_tf : Transform) -> Vector3:

	var step_pos_global := global_tf * local_2d_to_3d(local_translate)
	var next_pos_global := projected_position(height, step_pos_global)

	return next_pos_global - global_tf.origin

static func adjusted_orientation(global_tf : Transform) -> Basis:
	var forward_dir_global := global_tf.basis * Vector3.FORWARD
	var new_up_dir_global := global_tf.origin.normalized()
	var new_left_dir_global := new_up_dir_global.cross(forward_dir_global).normalized()
	var new_forward_dir_global := new_left_dir_global.cross(new_up_dir_global)

	return Basis(
		-new_left_dir_global,
		new_up_dir_global,
		-new_forward_dir_global)
