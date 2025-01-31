extends Node2D
class_name Creature

## Node References ##
@onready var BodyShape = $Shape
@onready var Outline = $Outline
@onready var Line = $Line # "Spine"
@onready var Eyes = $Eyes

@onready var anchor : Marker2D = $Points/Anchor
@onready var anchor_direction = (get_global_mouse_position() - anchor.position).angle()
var points : Array[Node]

## Creature Variables ##
@export var FollowsMouse : bool = true
@export_color_no_alpha var BodyColor = Color.BLACK
@export var SegmentLength = 50
@export var CreatureWidth : Curve
var PointAmount = 0
var SegmentSize : Array[float] = []

var target_position : Vector2

func _ready() -> void:
	initialize_creature()

func _process(delta : float) -> void:
	update_creature(delta)


## Sets up Creature ##
func initialize_creature() -> void:
	PointAmount = CreatureWidth.bake_resolution - 2
	SegmentSize.resize(CreatureWidth.bake_resolution)
	
	for i : float in CreatureWidth.bake_resolution:
		SegmentSize[i] = CreatureWidth.sample(i/CreatureWidth.bake_resolution)
	
	# Add the points to the creature's body
	for point in PointAmount:
		$Points.add_child($Points/Point.duplicate(8))
	
	points = $Points.get_children() # Adds Point Marker nodes to an array
	
	# Adds blank points to the Spine and Outline of the creature
	for point in points:
		Line.add_point(Vector2.ZERO)
		
		Outline.add_point(Vector2.ZERO)
		Outline.add_point(Vector2.ZERO)
	
	BodyShape.color = BodyColor # Sets color


## Updates creature Position and Body ##
func update_creature(delta : float) -> void:
	## Left and Right Points of the creature
	# These two arrays together will make the body shape of the creature
	var left : PackedVector2Array = []
	var right : PackedVector2Array = []
	
	## Gets Target position
	if FollowsMouse:
		target_position = get_global_mouse_position()
	elif $Timer.is_stopped():
		target_position = random_movement()
		$Timer.start()
	
	## Turns and moves the creature towards target position ##
	var target_direction = (target_position - anchor.position).angle()
	anchor_direction = lerp_angle(anchor_direction, target_direction, delta)
	var speed : Vector2 = Vector2.from_angle(anchor_direction) * 3
	anchor.position += speed
	
	Eyes.position = anchor.position
	Eyes.rotation = anchor_direction
	
	## Angle Constraint
	#if points.size() > i+1:
		#var next_point : Marker2D = points[i+1]
		#var angle_1 = point.get_angle_to(previous_point.position)
		#var angle_2 = point.get_angle_to(next_point.position)
		#
		#var angle_difference = absf(angle_difference(angle_1, angle_2))
		#if angle_difference < 2.8:
			#var desired_angle = rad_to_deg(lerp_angle(angle_2, angle_1, 0.01))
			#desired_angle = Vector2.from_angle(desired_angle)
			#
			#next_point.position = point.position + desired_angle * point.position.distance_to(next_point.position)
	
	## Calculates Tip, Left and Right side of Anchor circle ##
	var left_side_x = SegmentSize[0] * cos(anchor_direction - PI / 2)
	var left_side_y = SegmentSize[0] * sin(anchor_direction - PI / 2)
	var left_pos = anchor.position + Vector2(left_side_x, left_side_y)
	
	var right_side_x = SegmentSize[0] * cos(anchor_direction + PI / 2)
	var right_side_y = SegmentSize[0] * sin(anchor_direction + PI / 2)
	var right_pos = anchor.position + Vector2(right_side_x, right_side_y)
	
	left.append(left_pos)
	right.append(right_pos)
	
	
	## Loops through Points to update and get their position ##
	var i = 0
	for point : Marker2D in points:
		# Anchor is updated before, outside of this loop
		if point != anchor:
			# Points are moved to stay in a certain distance
			# away from the previous point in the chain
			var previous_point : Marker2D = points[i-1]
			if (point.position - previous_point.position).length() != SegmentLength:
				var direction = previous_point.position.direction_to(point.position)
				point.position = previous_point.position + direction * SegmentLength
				
				
				# Calculates Left and Right side of Point circle
				var direction_rad = (-direction).angle()
				left_side_x = SegmentSize[i] * cos(direction_rad - PI / 2)
				left_side_y = SegmentSize[i] * sin(direction_rad - PI / 2)
				left_pos = point.position + Vector2(left_side_x, left_side_y)
				
				right_side_x = SegmentSize[i] * cos(direction_rad + PI / 2)
				right_side_y = SegmentSize[i] * sin(direction_rad + PI / 2)
				right_pos = point.position + Vector2(right_side_x, right_side_y)
				
				left.append(left_pos)
				right.append(right_pos)
		# Adds points to Spinal Line
		Line.set_point_position(i, Line.to_local(point.position))
		
		i += 1
	
	## Reverse right side, join both sides together and set points to Outline and Body Shape ##
	right.reverse()
	left.append_array(right)
	Outline.points = left
	BodyShape.polygon = left

## Handles movement of the creature ##
func random_movement():
	var x = randi_range(20, 1900)
	var y = randi_range(20, 1060)
	return Vector2(x, y)
