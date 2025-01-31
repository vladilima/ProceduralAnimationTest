extends Node2D

## Node References ##
@onready var Line : Line2D = $Arm_Line
@onready var Outline : Line2D = $Outline
@onready var TargetMarker : Marker2D = $Target
@onready var Points : Array[Node] = $Arm.get_children()

## Limb Parameters ##
@export var segment_length : int = 64
@export var targeting_mouse : bool = false
@export var reverse_elbow : bool = false
@export var limb_color : Color = Color.WHITE
var going_up : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Line.default_color = limb_color


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var target_pos = TargetMarker.global_position
	if targeting_mouse:
		target_pos = get_global_mouse_position()
		TargetMarker.global_position = target_pos
		look_at(target_pos)
	#else:
		#if left_side:
			#target_pos.x = -segment_length * 1.5
		#else:
			#target_pos.x = segment_length * 1.5
		#
		#if target_pos.y < -segment_length or not going_up:
			#target_pos.y += delta * 400
			#going_up = false
		#if target_pos.y > segment_length or going_up:
			#target_pos.y -= delta * 900
			#going_up = true
		#look_at(target_pos)
	
	var distance = (global_position - target_pos).length()
	
	var angle = acos(distance / (segment_length * 2))
	
	if reverse_elbow:
		angle = -angle
	
	var elbow_pos = Vector2(cos(angle) * segment_length, sin(angle) * segment_length)
	var hand_pos = clamp(distance, 0, segment_length * 2)
	$Arm/Elbow.position = elbow_pos
	$Arm/Hand.position.x = hand_pos
	
	Line.clear_points()
	var i = 0
	var outline_radius = 10
	var left_side : Array
	var right_side : Array
	
	
	
	var direction = ($Arm/Shoulder.position - $Arm/Shoulder.position).angle()
	angle = get_angle_to($Arm/Elbow.global_position)
	
	var left_side_shoulder_x = outline_radius * cos(angle - PI / 2)
	var left_side_shoulder_y = outline_radius * sin(angle - PI / 2)
	left_side.append($Arm/Shoulder.position + Vector2(left_side_shoulder_x, left_side_shoulder_y))
	
	var right_side_shoulder_x = outline_radius * cos(angle + PI / 2)
	var right_side_shoulder_y = outline_radius * sin(angle + PI / 2)
	right_side.append($Arm/Shoulder.position + Vector2(right_side_shoulder_x, right_side_shoulder_y))
	
	for point in Points:
		Line.add_point(point.position)
	
	
	var outline_offset = 10
	if reverse_elbow:
		outline_offset = -10
	
	direction = Points[1].position.direction_to(Points[2].position)
	angle = direction.angle()
	var left_side_x = outline_radius * cos(angle - PI / 2)
	var left_side_y = outline_radius * sin(angle - PI / 2)
	left_side.append(Points[1].position + Vector2(left_side_x + outline_offset, left_side_y + outline_offset * angle))
	
	var right_side_x = outline_radius * cos(angle + PI / 2)
	var right_side_y = outline_radius * sin(angle + PI / 2)
	right_side.append(Points[1].position + Vector2(right_side_x - outline_offset, right_side_y - outline_offset * angle))
	
	left_side_x = outline_radius * cos(angle - PI / 2)
	left_side_y = outline_radius * sin(angle - PI / 2)
	left_side.append(Points[2].position + Vector2(left_side_x, left_side_y))
	
	right_side_x = outline_radius * cos(angle + PI / 2)
	right_side_y = outline_radius * sin(angle + PI / 2)
	right_side.append(Points[2].position + Vector2(right_side_x, right_side_y))
	
	
	
	right_side.reverse()
	left_side.append_array(right_side)
	Outline.points = left_side
