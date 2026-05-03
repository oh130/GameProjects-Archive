extends Node2D

var space_state : PhysicsDirectSpaceState2D

func initialize():
	space_state = get_world_2d().direct_space_state

func wide_attack(pos : Vector2, reach : int, damage : int, arm_pen : bool):
	var query := PhysicsShapeQueryParameters2D.new()
	var shape := CircleShape2D.new()
	shape.radius = GameManager.get_reach(reach)
	query.set_shape(shape)
	query.transform = Transform2D(Vector2.RIGHT, 0.5 * Vector2.DOWN, pos)
	
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.collision_mask = 5

	var results := space_state.intersect_shape(query)
	
	for result in results:
		result.collider.take_damage(damage, arm_pen)
