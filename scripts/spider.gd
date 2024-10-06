extends Node3D

@onready
var _init_pos: Vector3 = self.global_position;
var _leap_target: Node3D = null;
var _gravity: float = 9.81;
var _speed: float = 0.0;

func _physics_process(delta: float) -> void:
	if self._leap_target == null:
		self._speed += _gravity * delta;
		var frame_speed = self._speed * delta;
		var v: Vector3 = self._init_pos - self.global_position;
		if v.length() <= frame_speed:
			# reached the initial position
			self.global_position = self._init_pos;
			self._speed = 0.0;
		else:
			self.global_position += v.normalized() * frame_speed;
	else:
		# total distance to target
		var total_dist = self._leap_target.global_position.distance_to(self._init_pos);
		# current distance to target
		var current_v = self._leap_target.global_position - self.global_position;
		var pending_progress = current_v.length() / total_dist;
		# quadratic easing to simulate gravity
		var frame_speed := pow(pending_progress, 2) * _gravity * delta;
		self.global_position += current_v.normalized() * frame_speed;

func _on_detection_area_area_entered(area: Area3D) -> void:
	if self._leap_target != null:
		# already have a target
		return;
	self._leap_target = area.get_parent() as Node3D

func _on_collision_area_area_entered(area: Area3D) -> void:
	var target: Node3D = area.get_parent() as Node3D;
	if target != self._leap_target:
		# not the target
		return;
	self._leap_target = null;
	# TODO: kill the target!
