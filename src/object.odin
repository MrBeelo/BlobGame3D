package bg3d

import rl "vendor:raylib"

objects : [dynamic]Object

Object :: struct {
	model: rl.Model,
	pos: rl.Vector3,
	rot: rl.Vector3,
	scale: rl.Vector3,
	shader_types: []MaterialShaderType,
	collidable: bool,
	name: string,
	order: MatrixRotationOrder,
	room_number: int,
	force_draw: bool,
	should_draw: bool,
	bad_object: bool
}

NewObject :: proc(model: rl.Model, pos: rl.Vector3, rot: rl.Vector3 = {}, scale: rl.Vector3 = {1, 1, 1}, 
shader_types: []MaterialShaderType = {}, collidable: bool = true, name: string = "No Name", order: MatrixRotationOrder = MatrixRotationOrder.XYZ, 
room_number := int(0), force_draw := false, should_draw := true) -> Object {
	copied_shader_types := make([]MaterialShaderType, len(shader_types))
    for i in 0..<len(shader_types) do copied_shader_types[i] = shader_types[i]
	return Object{model, pos, rot, scale, copied_shader_types, collidable, name, order, room_number, force_draw, should_draw, false}
}

NewBadObject :: proc() -> Object {
	return Object{blob_model, {}, {}, {}, {}, false, "Bad Object", .XYZ, 0, false, false, true}
}

UpdateObjects :: proc(objs: [dynamic]Object = objects) {
	for &obj in (objs) do UpdateObject(&obj)
}

DrawObjects :: proc(objs: [dynamic]Object = objects) {
	for &obj in (objs) do DrawObject(&obj)
}

UpdateObject :: proc(self: ^Object) {
	if(self.bad_object) do return
	UpdateFlashlight(self)
	UpdateTriggers(self)
}

DrawObject :: proc(self: ^Object) {
	if(self.bad_object) do return
	is_seen := FrustumContainsBox(GetCameraFrustum(&player), GetObjectBoundingBox(self^))
	if(!is_seen && !self.force_draw) do return
	AssignMaterialMaps(self.shader_types)
	if(self.should_draw) do DrawModelPro(&self.model, self.pos, {rad(self.rot.x), rad(self.rot.y), rad(self.rot.z)}, self.scale, rl.WHITE, self.order)
	if(f3) do DrawBoundingBox(GetObjectBoundingBox(self^))
}

GetObjectBoundingBox :: proc(obj: Object) -> rl.BoundingBox {
	bbox := rl.GetModelBoundingBox(obj.model)
	bbox.min = bbox.min * obj.scale + obj.pos
    bbox.max = bbox.max * obj.scale + obj.pos
    return bbox
}

DrawBoundingBox :: proc(box: rl.BoundingBox) {
	center := (box.min + box.max) / 2
	size: rl.Vector3 = box.max - box.min
	rl.DrawCubeWiresV(center, size, rl.RED)
}