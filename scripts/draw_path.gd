extends Node3D

@onready var player_path = $PlayerPath
@onready var player_follow = $PlayerPath/PlayerPathFollow
@onready var player = $PlayerPath/PlayerPathFollow/Player

var path_draw_ongoing: bool = false
var temp_curve: Curve3D = Curve3D.new()
var latest_point: Vector3 = Vector3()
var in_free_move: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_follow.loop = false

func _physics_process(delta):
	player_follow.progress += delta * 0.2
	if Input.is_action_just_released("click"):
		path_draw_ongoing = false
		if temp_curve.point_count <= 0:
			return
		var last_point = temp_curve.get_point_position(temp_curve.get_point_count() - 1)
		var second_last_point = temp_curve.get_point_position(temp_curve.get_point_count() - 2)
		var direction = (last_point - second_last_point).normalized()
		temp_curve.add_point(last_point + direction * 100)
		player_path.curve = temp_curve
	
	if path_draw_ongoing:
		mouse_path()


func mouse_path():
	var pos = get_viewport().get_mouse_position()
	var cam = get_tree().root.get_camera_3d()
	pos = cam.project_position(pos, 1.0)
	latest_point = pos
	var last_point: Vector3 = player.global_position
	if temp_curve.point_count > 0:
		last_point = temp_curve.get_point_position(temp_curve.point_count-1)
	
	if last_point.distance_to(latest_point) > 0.025:
		temp_curve.add_point(pos)


func _on_area_3d_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		player_follow.progress = 0
		temp_curve.clear_points()
		path_draw_ongoing = true
