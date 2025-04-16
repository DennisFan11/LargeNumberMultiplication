extends Line2D
var Missions:Array = []
func move() -> void:
	points = [
		Missions[0].global_position,
		Missions[1].global_position
	]
	
