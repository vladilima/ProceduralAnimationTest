extends Creature

## Node References ##
@onready var FrontFins = $Fins1
@onready var BackFins = $Fins2
@onready var TailFin = $TailFin
@onready var TailFinShape = $TailFin/Polygon2D
@onready var DorsalFin = $DorsalFin
@onready var DorsalFinShape = $DorsalFin/Polygon2D

## Fish Variables ##
var FishCurvature : float = 0
var SecondaryColor : Color

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initialize_creature()
	
	SecondaryColor = BodyColor.lightened(.35)
	FrontFins.modulate = SecondaryColor
	BackFins.modulate = SecondaryColor
	TailFinShape.color = SecondaryColor
	DorsalFinShape.color = SecondaryColor


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta : float) -> void:
	update_creature(delta)
	
	## Moves and Rotates lateral fins ##
	var FrontFinAngle = points[10].get_angle_to(points[9].position)
	FrontFins.position = points[15].position
	FrontFins.rotation = FrontFinAngle
	
	var BackFinAngle = points[24].get_angle_to(points[23].position)
	BackFins.position = points[29].position
	BackFins.rotation = BackFinAngle
	
	
	## Calculates how much the whole body is curving ##
	var i = 0
	var TotalBodyCurvature : float = 0
	var CurvatureAxis : float = 0
	for point : Marker2D in points:
		if point != anchor and points.size() > i+1:
			var next_angle = point.get_angle_to(points[i+1].position)
			var previous_angle = point.get_angle_to(points[i-1].position)
			
			CurvatureAxis += angle_difference(next_angle, previous_angle)
			
			var degree_diff = rad_to_deg(next_angle) - rad_to_deg(previous_angle)
			TotalBodyCurvature += absf(180 - absf(degree_diff))
		
		i += 1
	
	CurvatureAxis = clampf(CurvatureAxis, -1, 1)
	FishCurvature = lerp(FishCurvature, CurvatureAxis, delta * 3)
	TotalBodyCurvature = FishCurvature * -TotalBodyCurvature / 10
	
	
	## Moves and Rotates Tail Fin ##
	var TailFinAngle = points[49].get_angle_to(points[48].position)
	TailFin.position = points[49].position
	TailFin.rotation = TailFinAngle
	
	var LeftTailFin = [0, 1, 2]
	var RightTailFin = [5, 4, 3]
	
	var FinShape = TailFinShape.get_polygon()
	for j in 3:
		FinShape[LeftTailFin[j]].y = clamp(j * TotalBodyCurvature, -20, -2)
		FinShape[RightTailFin[j]].y = clamp(j * TotalBodyCurvature, 2, 20)
	
	TailFinShape.set_polygon(FinShape)
	$TailFin/Line2D.set_points(FinShape)
	
	
	## Moves and Offsets Dorsal Fin
	var DorsalFinLength = 10
	var DorsalFinLeftSide : Array
	var DorsalFinRightSide : Array
	var DorsalFinPolygon : Array
	
	var j = 0
	for point in points:
		if j > 16 and j < 30:
			var point_position = point.position
			DorsalFinLeftSide.append(point_position)
			
			var fin_offset : float = absi(absi(j - 23) - 6)
			point_position.y += clamp((-TotalBodyCurvature / 4) * fin_offset, -30, 30)
			
			DorsalFinRightSide.append(point_position)
		j += 1
	
	DorsalFinRightSide.reverse()
	DorsalFinLeftSide.append_array(DorsalFinRightSide)
	DorsalFinPolygon = DorsalFinLeftSide
	
	DorsalFinShape.set_polygon(DorsalFinPolygon)
	$DorsalFin/Line2D.points = DorsalFinPolygon
