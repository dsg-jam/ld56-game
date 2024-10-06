extends Node3D

var _target: Node3D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_3d_area_entered(area: Area3D) -> void:
	if self._target != null:
		return
	if not area.is_in_group("firefly"):
		return
	self._target = area.get_parent()
	self._target.get_parent().get_parent().get_parent().initiate_approach(self.global_position)


func _on_detection_area_area_exited(area: Area3D) -> void:
	if self._target == null:
		return
	if not area.is_in_group("firefly"):
		return
	if area.get_parent() != self._target:
		return
	self._target = null
