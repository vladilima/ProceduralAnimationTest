extends Creature

## Node References ##
@onready var FrontLeftLeg = $Legs/FrontLeftLeg
var front_left_target : Vector2 = Vector2.ZERO
@onready var FrontRightLeg = $Legs/FrontRightLeg
var front_right_target : Vector2 = Vector2.ZERO

@onready var BackLeftLeg = $Legs/BackLeftLeg
var back_left_target : Vector2 = Vector2.ZERO
@onready var BackRightLeg = $Legs/BackRightLeg
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
	
	
	# Back Leg Positions #
	var BackLegsAngle = points[40].get_angle_to(points[39].position)
	var BackLegPos = parametric_constructor(SegmentSize[40], BackLegsAngle)
	BackLeftLeg.position = points[40].position - BackLegPos / 2
	BackRightLeg.position = points[40].position + BackLegPos / 2
	
	
	# Leg Targets
	var i = 0
	for Leg : Node2D in Legs:
		# Offset for each side
		var neg = -1
		if i % 2 == 0:
			neg = 1
		
		# Front Legs
		if i < 2:
			if Leg.target_pos.distance_to(points[20].global_position) > Leg.segment_length * 2.5:
				var tween : Tween = get_tree().create_tween()
				var new_target_pos = points[14].global_position - FrontLegPos * 2 * neg
				tween.tween_property(Leg, "target_pos", new_target_pos, .1)
		
		# Back Legs
		if i >= 2:
			if Leg.target_pos.distance_to(points[40].global_position) > Leg.segment_length * 3:
				var tween : Tween = get_tree().create_tween()
				var new_target_pos = points[35].global_position - BackLegPos * 2 * neg
				tween.tween_property(Leg, "target_pos", new_target_pos, .1)
		
		Leg.look_at(Leg.target_pos)
		
		i += 1


# Returns Vector2 result of parametric equation
func parametric_constructor(radius, angle) -> Vector2:
	var circle_point_x = radius * cos(angle + PI / 2)
	var circle_point_y = radius * sin(angle + PI / 2)
	
	return Vector2(circle_point_x, circle_point_y)
