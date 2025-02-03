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

@onready var target_pos : Vector2 = TargetMarker.global_position
@onready var elbow_pos : Vector2 = Vector2(segment_length, 0)
@onready var hand_pos : float = segment_length * 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Line.default_color = limb_color


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if targeting_mouse:
		target_pos = get_global_mouse_position()
		TargetMarker.global_position = target_pos
		look_at(target_pos)
	
	var distance = (global_position - target_pos).length()
	
	var angle = acos(distance / (segment_length * 2))
	
	if reverse_elbow:
		angle = -angle
	
	elbow_pos = Vector2(cos(angle) * segment_length, sin(angle) * segment_length)
	hand_pos = clamp(distance, 0, segment_length * 2)
	$Arm/Elbow.position = elbow_pos
	$Arm/Hand.position.x = hand_pos
	
	Line.clear_points()
	$Outline.clear_points()
	for point in Points:
		Line.add_point(point.position)
		$Outline.add_point(point.position)
	
	queue_redraw()

func _draw() -> void:
	draw_circle($Arm/Hand.position, 25, Color.WHITE)
	draw_circle($Arm/Hand.position, 20, limb_color)
