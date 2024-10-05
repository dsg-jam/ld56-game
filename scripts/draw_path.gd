extends Node3D

@export var speed: float = 0.2
@export var height: float = 0.0
@export var min_mouse_movement: float = 2.0 / 64.0
@export var max_path_length: float = 2.0 / 256.0

@onready var _player_path = $PlayerPath
@onready var _player_follow = $PlayerPath/PlayerPathFollow

var _path_draw_ongoing: bool = false
var _current_dir: Vector3 = Vector3(1,0,0)
var _offset: Vector3 = Vector3.ZERO
var _handled_line_idx: int = 0
var _path_lines: Array = []

func _ready() -> void:
	self._player_follow.loop = false

func _physics_process(delta):
	self._clean_up_path()
	
	if self._player_follow.progress_ratio >= 1.0:
		self._player_path.curve.clear_points()
		self._player_follow.progress_ratio = 0
		self._path_draw_ongoing = false
	
	if self._player_path.curve.point_count <= 0:
		set_global_position(global_position + delta * self._current_dir * speed)
		self._offset += delta * self._current_dir * speed
	else:
		self._player_follow.progress += delta * speed
	
	if Input.is_action_just_released("click"):
		self._path_draw_ongoing = false
		
	if self._path_draw_ongoing:
		self._mouse_path()

func _draw_line(from: Vector3, to: Vector3) -> MeshInstance3D:
	var instance: MeshInstance3D = LineSpawner.draw_line(from, to, Color.WHITE, 0.005)
	self._player_path.add_child(instance)
	return instance

func _clean_up_path():
	if len(self._path_lines) <= 0:
		return
	
	var progress = self._player_follow.progress_ratio
	var idx = int(self._player_path.curve.point_count * progress)
	for _i in range(idx - self._handled_line_idx):
		var l = self._path_lines.pop_front()
		l.queue_free()
	self._handled_line_idx = idx

func _mouse_path():
	var mouse_pos = get_viewport().get_mouse_position()
	var cam = get_tree().root.get_camera_3d()
	var depth = cam.global_position.y - height
	var next_pos: Vector3 = get_tree().root.get_camera_3d().project_position(mouse_pos, depth)
	
	next_pos -= self._offset
	
	var prev_pos = Vector3.INF
	if self._player_path.curve.point_count > 0:
		prev_pos = self._player_path.curve.get_point_position(self._player_path.curve.point_count-1)
	
	if prev_pos.distance_to(next_pos) >= min_mouse_movement:
		self._add_path(prev_pos, next_pos)


func _add_path(from: Vector3, to: Vector3):
	var total_distance = from.distance_to(to)
	self._current_dir = from.direction_to(to).normalized()
	if from.is_equal_approx(Vector3.INF):
		self._player_path.curve.add_point(to)
		self._path_lines.append(self._draw_line(to, to))
		return
	var current_distance = 0.0
	while current_distance < total_distance:
		var prev_distance = current_distance
		current_distance += max_path_length
		self._player_path.curve.add_point(from + current_distance * self._current_dir)
		var line = self._draw_line(from + prev_distance * self._current_dir, from + current_distance * self._current_dir)
		self._path_lines.append(line)


func _on_area_3d_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		self._player_path.curve.clear_points()
		self._player_follow.progress_ratio = 0
		self._path_draw_ongoing = true
		for l in self._path_lines:
			l.queue_free()
		self._path_lines = []
		self._handled_line_idx = 0
