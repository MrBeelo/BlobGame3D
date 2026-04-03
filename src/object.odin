package bb3d

import "core:fmt"
import rl "vendor:raylib"

objects : [dynamic]Object

Object :: struct {
	model: rl.Model,
	pos: rl.Vector3,
	rot_axis: rl.Vector3,
	rot_angle: f32,
	scale: rl.Vector3,
	types: []MaterialShaderType, // Normal, Roughness
	name: string
}

NewObject :: proc(model: rl.Model, pos: rl.Vector3, rot_axis: rl.Vector3 = {}, rot_angle: f32 = 0, 
scale: rl.Vector3 = {1, 1, 1}, types: []MaterialShaderType = {}, name: string = "No Name") -> Object {
	copied_types := make([]MaterialShaderType, len(types))
    for i in 0..<len(types) do copied_types[i] = types[i]
	return Object{model, pos, rot_axis, rot_angle, scale, copied_types, name}
}

UpdateObjects :: proc() {
	for &obj in (objects) do UpdateObject(&obj)
}

DrawObjects :: proc() {
	for &obj in (objects) do DrawObject(&obj)
}

UpdateObject :: proc(self: ^Object) {
	UpdateFloor(self)
}

DrawObject :: proc(self: ^Object) {
	is_seen := FrustumContainsBox(GetCameraFrustum(&player), GetObjectBoundingBox(self^))
	if(!is_seen) do return
	AssignMaterialMaps(self.types)
	rl.DrawModelEx(self.model, self.pos, self.rot_axis, self.rot_angle, self.scale, rl.WHITE)
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