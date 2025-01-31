extends Creature

## Node References ##
@onready var FrontLeftLeg = $Legs/FrontLeftLeg
@onready var FrontRightLeg = $Legs/FrontRightLeg
var front_left_target : Vector2 = Vector2.ZERO
var front_right_target : Vector2 = Vector2.ZERO

@onready var BackLeftLeg = $Legs/BackLeftLeg
@onready var BackRightLeg = $Legs/BackRightLeg
var back_left_target : Vector2 = Vector2.ZERO
var back_right_target : Vector2 = Vector2.ZERO

var Legs : Array[Node]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initialize_creature()
	
	var SecondaryColor = BodyColor.lightened(.3)
	
	Legs = $Legs.get_children()
	for Leg in Legs:
		Leg.limb_color = SecondaryColor
		Leg._ready()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_creature(delta)
	
	## Moves and Handles Legs ##
	
	# Front Leg Positions #
	var FrontLegsAngle = points[20].get_angle_to(points[19].position)
	var FrontLegPos = parametric_constructor(SegmentSize[20], FrontLegsAngle)
	FrontLeftLeg.position = points[20].position - FrontLegPos / 2
	FrontRightLeg.position = points[20].position + FrontLegPos / 2
	
	# Front Leg Targets
	if FrontLeftLeg.TargetMarker.global_position.distance_to(points[20].global_position) > FrontLeftLeg.segment_length * 2.5:
		front_left_target = points[14].global_position - FrontLegPos * 2
	FrontLeftLeg.TargetMarker.global_position = front_left_target
	FrontLeftLeg.look_at(front_left_target)

	if FrontRightLeg.TargetMarker.global_position.distance_to(points[20].global_position) > FrontRightLeg.segment_length * 2.5:
		front_right_target = points[14].global_position + FrontLegPos * 2
	FrontRightLeg.TargetMarker.global_position = front_right_target
	FrontRightLeg.look_at(front_right_target)
	
	
	# Back Leg Positions #
	var BackLegsAngle = points[40].get_angle_to(points[39].position)
	var BackLegPos = parametric_constructor(SegmentSize[40], BackLegsAngle)
	BackLeftLeg.position = points[40].position - BackLegPos / 2
	BackRightLeg.position = points[40].position + BackLegPos / 2
	
	# Back Leg Targets
	if BackLeftLeg.TargetMarker.global_position.distance_to(points[40].global_position) > BackLeftLeg.segment_length * 3:
		back_left_target = points[35].global_position - BackLegPos * 2
	BackLeftLeg.TargetMarker.global_position = back_left_target
	BackLeftLeg.look_at(back_left_target)
	
	if BackRightLeg.TargetMarker.global_position.distance_to(points[40].global_position) > BackRightLeg.segment_length * 3:
		back_right_target = points[35].global_position + BackLegPos * 2
	BackRightLeg.TargetMarker.global_position = back_right_target
	BackRightLeg.look_at(back_right_target)


# Returns Vector2 result of parametric equation
func parametric_constructor(radius, angle) -> Vector2:
	var circle_point_x = radius * cos(angle + PI / 2)
	var circle_point_y = radius * sin(angle + PI / 2)
	
	return Vector2(circle_point_x, circle_point_y)
