extends Node

func draw_line(from: Vector3, to: Vector3, color: Color, width: float) -> MeshInstance3D:
	var mesh: ImmediateMesh
	var mesh_instance: MeshInstance3D
	var material: StandardMaterial3D
	var d: Vector3 = from.direction_to(to)
	var n: Vector3 = d.rotated(Vector3(0,1,0), PI/2).normalized()
	n *= width
	
	var p1 = from - n
	var p2 = from + n
	var p3 = to - n
	var p4 = to + n
	
	
	mesh = ImmediateMesh.new()
	material = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.no_depth_test = true
	material.vertex_color_use_as_albedo = true
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = mesh
	mesh_instance.material_override = material
	
	mesh.surface_begin(PrimitiveMesh.PRIMITIVE_TRIANGLES)
	mesh.surface_set_color(color)
	mesh.surface_add_vertex(p1)
	mesh.surface_add_vertex(p2)
	mesh.surface_add_vertex(p3)
	mesh.surface_add_vertex(p3)
	mesh.surface_add_vertex(p4)
	mesh.surface_add_vertex(p2)
	mesh.surface_end()

	return mesh_instance
