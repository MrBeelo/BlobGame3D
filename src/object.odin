package bb3d

import "core:fmt"
import rl "vendor:raylib"

objects : [dynamic]Object

Object :: struct {
	model: rl.Model,
	pos: rl.Vector3,
	rot: rl.Vector3,
	scale: rl.Vector3,
	types: []MaterialShaderType, // Normal, Roughness
	collidable: bool,
	name: string,
	order: MatrixRotationOrder,
	force_draw: bool,
	should_draw: bool
}

NewObject :: proc(model: rl.Model, pos: rl.Vector3, rot: rl.Vector3 = {}, scale: rl.Vector3 = {1, 1, 1}, 
types: []MaterialShaderType = {}, collidable: bool = true, name: string = "No Name", order: MatrixRotationOrder = MatrixRotationOrder.XYZ, 
force_draw := false, should_draw := true) -> Object {
	copied_types := make([]MaterialShaderType, len(types))
    for i in 0..<len(types) do copied_types[i] = types[i]
	return Object{model, pos, rot, scale, copied_types, collidable, name, order, force_draw, should_draw}
}

UpdateObjects :: proc(objs: [dynamic]Object = objects) {
	for &obj in (objs) do UpdateObject(&obj)
}

DrawObjects :: proc(objs: [dynamic]Object = objects) {
	for &obj in (objs) do DrawObject(&obj)
}

UpdateObject :: proc(self: ^Object) {
	UpdateFloor(self)
	UpdateFlashlight(self)
}

DrawObject :: proc(self: ^Object) {
	is_seen := FrustumContainsBox(GetCameraFrustum(&player), GetObjectBoundingBox(self^))
	if(!is_seen && !self.force_draw) do return
	AssignMaterialMaps(self.types)
	DrawModelPro(&self.model, self.pos, Vector3ToRadians(self.rot), self.scale, rl.WHITE, self.order)
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